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

    my $plugin = MT->component('RelatedItems');
    my $config = $plugin->get_config_hash( 'blog:' . $blog_id );
    my $count  = $config->{related_items_count};

    my $html = <<"HTML";
<link rel="stylesheet" href="<mt:PluginStaticWebPath component="relateditems">css/ri_styles.css" />
<div class="ri_tag_div"><input class="" type="text" name="<mt:var name="field_name">" 
       id="<mt:var name="field_id">" value="<mt:Var name="field_value" escape="html">" size="40"> <label>Show preview <input name="ri_<mt:var name="field_name">_show_preview" id="ri_<mt:var name="field_name">_show_preview" type="checkbox" value="show_preview" checked="checked" /></label></div>
<script type="text/javascript">
\$(function(){
	var source_type = "$source_type";
	var source_id = "$source_id";
    var field_name = '<mt:var name="field_name">';
    var preview_switch_id = '#ri_' + field_name + '_show_preview';
    var preview_id = '#ri_' + field_name + '_preview';
    var type="<mt:var name='options' />";
    var blog_id='<mt:var name="blog_id" />';

    if (typeof(RI_SCRIPT_LOADED) == "undefined" ) {
        \$.getScript("<mt:PluginStaticWebPath component="relateditems">js/ri_field.js", function(){
            setup_ri_field ( source_type, source_id, field_name, preview_switch_id, preview_id, type, blog_id );
        });
    } else {
        setup_ri_field ( source_type, source_id, field_name, preview_switch_id, preview_id, type, blog_id);
    }
});
var blog_id = $blog_id; 
var <mt:var name='field_name'>_type = '<mt:var name='options' />';
var count = '$count';
</script>
<fieldset id="">
<legend>Preview</legend>
<div id="ri_<mt:var name="field_id" />_preview">
</div>
</fieldset>
HTML

    return $html;
}

sub ri_list_related_items {
    my $app = shift;
    return $app->errtrans('This module works with MT::App::Search.')
        unless $app->isa('MT::App::Search');

    my ( $count, $out ) = $app->check_cache();
    if ( defined $out ) {
        $app->run_callbacks( 'search_cache_hit', $count, $out );
        return $out;
    }

    if ( $app->param('count') ) {
        $count = $app->param('count');
    }

    return $app->errtrans("Blog_id is required.")
        unless defined( $app->param('blog_id') );

    # what kind of object are we listing?
    return $app->errtrans("Type parameter is required.")
        unless $app->param('type');

    return $app->errtrans("Tags parameter is required.")
        unless $app->param('tags');

    return $app->errtrans("Basename parameter is required.")
        unless $app->param('basename');

    $out = _render( $app, $count );
    return unless $out;

    my $result;
    if ( ref($out) && ( $out->isa('MT::Template') ) ) {
        defined( $result = $out->build() )
            or return $app->error( $out->errstr );
    }
    else {
        $result = $out;
    }

    $count = $out->context()->stash('number_of_events');

    $app->run_callbacks( 'search_post_render', $app, $count, $result );

    my $cache_driver = $app->{cache_driver};
    $cache_driver->set( $app->{cache_keys}{count}, $count, $app->config->SearchCacheTTL );

    $result;
}

sub _render {
    my $app = shift;
    my ($count) = @_;

    my $blog_id = $app->param('blog_id');
    $blog_id =~ s/\D//g;
    my $blog = $app->model('blog')->load($blog_id)
        or return $app->errtrans('Invalid blog');

    my $source_type = $app->param('_type')
        or return $app->errtrans('No _type.');
    my $source_id = $app->param('id')
        or return $app->errtrans('No id.');

    my $basename = $app->param('basename');

    my $tag_var = $app->param('tags');
    $tag_var =~ s/,$/ /;
    if ( $tag_var =~ /,/ ) {
        my @tags_input = split( '\s?,\s?', $app->param('tags') );
        $tag_var = join( ' OR ', @tags_input );
    }
    my $plugin = MT->component("RelatedItems");
    my $config = $plugin->get_config_hash("blog:$blog_id");

    my $type          = $app->param('type');
    my $type_template = "ri_list_related_items.mtml";

    require MT::Template::Context;
    my $ctx = MT::Template::Context->new;
    $ctx->stash( 'blog',          $blog );
    $ctx->stash( 'blog_id',       $blog_id );
    $ctx->stash( 'local_blog_id', $blog_id );

    my $item = MT->model($source_type)->load($source_id)
        or return $app->errtrans("Couldn't load $source_type with id $source_id");
    $ctx->stash( $source_type, $item );

    $ctx->stash( 'count', $count ) if defined $count;

    my $vars = $ctx->{__stash}{vars} ||= {};
	
    $vars->{blogid}   = $blog_id;
    $vars->{basename} = $basename;
    $vars->{tags}     = $tag_var;
    $vars->{count}    = $count;
    $vars->{type}     = $type;

    my $tmpl_class = $app->model('template');

    my $tmpl = $plugin->load_tmpl($type_template);
    return $app->errtrans( 'Error loading template: [_1]', $type_template )
        unless $tmpl;

    $tmpl->context($ctx);

    return $tmpl;
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
