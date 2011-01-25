package RelatedItems::Tags;

use strict;
use warnings;
use Data::Dumper;

use RelatedItems::RelatedItemsField;

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

    my $cf_basename = $args->{basename};
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

    # my $class = $app->param('type');

    # Grab the field name with the collected data from above. The basename
    # must be unique so it's a good thing to key off of!
    my $field = CustomFields::Field->load(
        {   type     => 'related_items_tags',
            basename => $cf_basename,
        }
    );
    MT->log( Dumper($field) );

    if ( !$field ) { return $ctx->error('A Related Items Custom Field with this basename could not be found.'); }

    my $basename = 'field.' . $field->basename;
    my $obj_type = $field->obj_type;

    # Grab the correct object, based on the object type from the custom field.
    my $object;
    if ( $obj_type == 'entry' ) {
        $object = MT::Entry->load( { id => $ctx->stash('entry')->id, } );
    }
    elsif ( $obj_type == 'page' ) {

        # Entries and Pages are both stored in the mt_entry table
        $object = MT::Entry->load( { id => $ctx->stash('page')->id, } );
    }
    elsif ( $obj_type == 'category' ) {
        $object = MT::Category->load( { id => $ctx->stash('category')->id, } );
    }
    elsif ( $obj_type == 'folder' ) {

        # Categories and Folders are both stored in the mt_category table
        $object = MT::Category->load( { id => $ctx->stash('category')->id, } );
    }
    elsif ( $obj_type == 'author' ) {
        $object = MT::Author->load( { id => $ctx->stash('author')->id, } );
    }

    # $object0->$basename gets the value of the custom field for the object
    # in our case, the tags to use to calculate related items
    my $tags = $object->$basename;
    my @tags = split( /\s?,\s?/, $object->$basename );

}

1;
