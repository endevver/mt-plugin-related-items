package RelatedItems::RelatedItemsField;

use strict;
use warnings;
use Data::Dumper;

sub _options_field {

    my @classes = get_object_types();

    my $html = q{ <__trans phrase="Relate Items of Type">: <select name="options" id="options">};
    for my $c (@classes) {
        $html .= "<option value='$c'<mt:if name='options' eq='$c'> selected='selected'</mt:if>>"
            . "<__trans phrase='$c'></option>";
    }
    $html .= q{</select>};
    $html .= q{<p class="hint">Select what kind of items should be returned to the entry based on the tags.</p>};

    return $html;
}

sub _field_html {
    my $app     = MT->instance;
    my $blog    = $app->blog;
    my $blog_id = $blog->id;

    my $source_type = $app->param('_type');
    my $source_id   = $app->param('id');

    my $plugin       = MT->component('RelatedItems');
    my $config       = $plugin->get_config_hash( 'blog:' . $blog_id );
    my $count        = $config ? $config->{related_items_count} : 5;
    my $show_preview = $config ? $config->{related_items_show_preview} : 1;

    my $html = <<"HTML";
<link rel="stylesheet" href="<mt:PluginStaticWebPath component="relateditems">css/ri_styles.css" />
<div class="ri_tag_div textarea-wrapper">
    <input type="text" 
        name="<mt:Var name="field_name">" 
        id="<mt:Var name="field_id">" 
        value="<mt:Var name="field_value" escape="html">" 
        class="full-width ti"
        autocomplete="off" />
</div>
HTML

    if ($show_preview) {
        $html .= <<"HTML";
<script type="text/javascript">
\$(function(){
    var source_type = "$source_type";
    var source_id = "$source_id";
    var field_name = '<mt:var name="field_name">';
    var preview_switch_id = '#ri_' + field_name + '_show_preview';
    var preview_id = '#ri_' + field_name + '_preview';
    var type="<mt:var name='options' />";
    var blog_id='<mt:var name="blog_id" />';
    var count="$count";

    setup_ri_field ( 
        source_type, 
        source_id, 
        field_name, 
        preview_switch_id, 
        preview_id, 
        type, 
        blog_id, 
        count
    );
});

var blog_id = $blog_id; 
var <mt:var name='field_name'>_type = '<mt:var name='options' />';
var count = '$count';
</script>
<fieldset id="ri_<mt:var name="field_id" />_preview" class="ri_preview">
    <mt:Ignore>
        The title attribute needs to be specified with the legend. Otherwise, 
        everything gets a title of "undefined."
    </mt:Ignore>
    <legend title="A preview of the <mt:Var name="options"> tag search.">
        Preview
    </legend>
    <div class="preview_pane">
        <mt:Ignore>
            The following text should be almost immediately overwritten by 
            the AJAX load attempt.
        </mt:Ignore>
        <mt:If name="source_id">
            Nothing to preview. Enter comma-separated tags to search for a 
            matching <mt:Var name="options">.
        <mt:Else>
            This <mt:Var name="options"> must be saved before a preview can be 
            provided.
        </mt:If>
    </div>
</fieldset>
HTML
    }
    return $html;
}

sub ri_list_related_items {
    my $app = shift;

    my $args = {};

    # We've done a bunch of checking in the Javascript to ensure that the 
    # AJAX url is properly crafted, but trouble could still squeak through. 
    # Return errors as a piece of text (not $app-errstr) so that the error 
    # can be displayed without screwing up the page display.
    return "Blog_id parameter is required."
        unless defined( $app->param('blog_id') );

    # what kind of object are we listing?
    return "Type parameter is required."
        unless $app->param('type');

    return "Tags parameter is required."
        unless $app->param('tags');

    return "Basename parameter is required."
        unless $app->param('basename');

    my $blog_id = $app->param('blog_id');
    $blog_id =~ s/\D//g;
    my $blog = $app->model('blog')->load($blog_id)
        or return "Invalid blog";

    my $plugin = MT->component('relateditems');
    my $config = $plugin->get_config_hash( 'blog:' . $blog_id );

    my $count = $config ? $config->{'related_items_count'} : 5;

    if ( $app->param('count') ) {
        $count = $app->param('count');
    }
    my $terms = { blog_id => $blog_id, class => '*' };

    my $source_type = $app->param('_type')
        or return 'No _type.';
    my $source_id = $app->param('id')
        or return "This $source_type must be saved before a preview can be provided.";

    my $basename = $app->param('basename');

    my $type          = $app->param('type');
    my $type_template = "ri_list_related_items.mtml";

    my $ds = MT->model($type)->datasource;

    require MT::Tag;
    require MT::ObjectTag;

    my $tag_var = $app->param('tags');
    $tag_var =~ s/,$/ /;
    my @tag_names = $tag_var =~ /,/ ? split( '\s?,\s?', $tag_var ) : ($tag_var);

    my %tags = map { $_ => 1, MT::Tag->normalize($_) => 1 } @tag_names;
    my @tags = MT::Tag->load( { name => [ keys %tags ] } );
    my @tag_ids;
    foreach (@tags) {
        push @tag_ids, $_->id;
        my @more = MT::Tag->load( { n8d_id => $_->n8d_id ? $_->n8d_id : $_->id } );
        push @tag_ids, $_->id foreach @more;
    }
    @tag_ids = (0) unless @tags;

    $args->{'sort'}      = 'created_on';
    $args->{'direction'} = 'descend';

    # Count the total number of objects found. This is used for the "total 
    # count" display at the bottom of the returned object table. We need to 
    # use a  join *without* the limit argument so that we can collect all of 
    # the results.
    $args->{'join'} = [ 
        'MT::ObjectTag', 
        'object_id', 
        { tag_id => \@tag_ids, 
          object_datasource => $ds }, 
        { unique => 1, },
    ];

    my $total_count = MT->model($type)->count($terms,$args);

    # Now add the limit argument to the join, which will be used by
    # app:listing to generate the table.
    $args->{'join'}[3]{limit} = $count;

    my $hasher = sub {
        my ( $obj, $row ) = @_;
        if ( $row->{class} =~ /entry|page/ ) {
            $row->{name} = $row->{title};
            $row->{link} = $obj->permalink;
        }
        else {
            $row->{name} = $row->{label};
            $row->{link} = $obj->url;
        }
        $row->{label} = $row->{name};
    };

    return $app->listing(
        {   type     => $type,
            template => $plugin->load_tmpl($type_template),
            terms    => $terms,
            args     => $args,
            code     => $hasher,
            params   => {
                basename    => $basename,
                blogid      => $blog_id,
                basename    => $basename,
                tags        => $tag_var,
                count       => $count,
                type        => $type,
                total_count => $total_count,
            }
        }
    );
}

sub get_object_types {
    my $types = MT->registry('object_types');
    my @classes;
    foreach my $key ( keys %$types ) {
        next if $key =~ /(\w+\.\w+)|^file$|^(as|profileevent)$/;
        my $class = MT->model($key);
        push @classes, $key if $class->isa('MT::Taggable');
    }
    return @classes;
}

1;
