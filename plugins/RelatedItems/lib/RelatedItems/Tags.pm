package RelatedItems::Tags;

use strict;
use warnings;
use Data::Dumper;

use RelatedItems::RelatedItemsField;

# RelatedItems tag
#
# <mt:RelatedItems
#     basename='some_field_name'
#     [lastn='5']
# >
#
sub related_items_tag {
    my ( $ctx, $args, $cond ) = @_;
    my $builder = $ctx->stash('builder');
    my $tokens  = $ctx->stash('tokens');
    my $vars    = $ctx->{__stash}{vars} ||= {};

    my $res = '';

    my $blog    = $ctx->stash('blog');
    my $blog_id = $blog->id;

    my $plugin = MT->component('RelatedItems');
    my $config = $plugin->get_config_hash("blog:$blog_id");

    my $cf_basename   = $args->{basename};
    my $real_basename = $cf_basename;

    $real_basename =~ s/customfield_//;

    if ( !$cf_basename ) {
        return $ctx->error(
            'The RelatedItems block tag requires the basename argument. The basename should be the Related Items custom field basename.'
        );
    }

    # get count from args, or blog plugin setting (defaults to 5)
    my $count = $args->{lastn};
    if ( !$count ) {
        $count = $config->{related_items_count};
    }

    # accept a blog_id if you want related items from another blog
    if ( $args->{blog_id} ) {
        $blog_id = $args->{blog_id};
    }

    # Grab the field name with the collected data from above. The basename
    # must be unique so it's a good thing to key off of!
    my $field = CustomFields::Field->load(
        {   type     => 'related_items_tags',
            basename => $real_basename,
        }
    );

    if ( !$field ) {
        return $ctx->error("A Related Items Custom Field with this basename ($real_basename) could not be found.");
    }

    my $basename = 'field.' . $field->basename;
    my $obj_type = $field->obj_type;

    # Grab the correct object, based on the object type from the custom field.
    my $object;
    if ( $obj_type eq 'entry' ) {
        $object = MT::Entry->load( { id => $ctx->stash('entry')->id, } );
    }
    elsif ( $obj_type eq 'page' ) {

        # Entries and Pages are both stored in the mt_entry table
        if ( $ctx->stash('page') ) {
            $object = MT::Entry->load( { id => $ctx->stash('page')->id, } );
        }
        elsif ( $ctx->stash('entry') ) {
            $object = MT::Entry->load( { id => $ctx->stash('entry')->id, } );
        }
    }
    elsif ( $obj_type eq 'category' ) {
        $object = MT::Category->load( { id => $ctx->stash('category')->id, } );
    }
    elsif ( $obj_type eq 'folder' ) {

        # Categories and Folders are both stored in the mt_category table
        $object = MT::Category->load( { id => $ctx->stash('category')->id, } );
    }
    elsif ( $obj_type eq 'author' ) {
        $object = MT::Author->load( { id => $ctx->stash('author')->id, } );
    }

    # what kind of items are being related?
    my $type = $field->options;                # entry || asset || file || photo || image || video || whatever
    my $ds   = MT->model($type)->datasource;

    # $ds = $type =~ /file|image|video|photo/ ? 'asset' : $type;
    # print "setting ds to $ds for $type\n";

    my $class = MT->model($type);

    my %terms = ( 'blog_id' => $blog_id, class => '*' );
    my %args = ( 'desc' => 'DESC' );

    # $object->$basename gets the value of the custom field for the object
    # in our case, the tags to use to calculate related items
    my $tags = $object->$basename;
    my @tag_names = split( /\s?,\s?/, $object->$basename );

    require MT::Tag;
    require MT::ObjectTag;

    my %tags = map { $_ => 1, MT::Tag->normalize($_) => 1 } @tag_names;
    my @tags = MT::Tag->load( { name => [ keys %tags ] } );
    my @tag_ids;
    foreach (@tags) {
        push @tag_ids, $_->id;
        my @more = MT::Tag->load( { n8d_id => $_->n8d_id ? $_->n8d_id : $_->id } );
        push @tag_ids, $_->id foreach @more;
    }
    @tag_ids = (0) unless @tags;
    $args{'join'} =
        [ 'MT::ObjectTag', 'object_id', { tag_id => \@tag_ids, object_datasource => $ds }, { unique => 1 } ];

    my $num_items = $class->count( \%terms, \%args );

    $args{'lastn'} = $count;
    my @items = $class->load( \%terms, \%args );

    $vars->{object_loop} = \@items;
    $vars->{hide_pager}  = 1;

    $vars->{num_results} = $num_items;

    my $i = 0;
    foreach my $item (@items) {
        local $vars->{__first__}   = !$i;
        local $vars->{__last__}    = ( $i == ( scalar(@items) - 1 ) );
        local $vars->{__odd__}     = ( $i % 2 ) == 0;                    # 0-based $i
        local $vars->{__even__}    = ( $i % 2 ) == 1;
        local $vars->{__counter__} = $i + 1;

        # Assign the selected object
        local $ctx->{__stash}{$ds} = $item;

        my $out = $builder->build( $ctx, $tokens );
        if ( !defined $out ) {

            # A error--perhaps a tag used out of context. Report it.
            return $ctx->error( $builder->errstr );
        }
        $res .= $out;
        $i++;    # Increment for the meta vars.
    }
    return $res;
}

1;
