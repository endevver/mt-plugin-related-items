package RelatedItems::RelatedItemsField;

use strict;
use warnings;
use Data::Dumper;

use RelatedItems::Plugin;

sub _options_field {

    my @classes = RelatedItems::Plugin::get_object_types();

    my $html = q{ <__trans phrase="Relate Items of Type">: <select name="options" id="options">};
    for my $c (@classes) {
        $html .= "<option value='$c'<mt:if name='options' eq='$c'> selected='selected'</mt:if>>"
            . "<__trans phrase='$c'></option>";
    }
    $html .= q{</select>};
    $html .= q{[<mt:Var name="options" escape="html">]};
    $html .= q{<p class="hint">Select what kind of items should be returned to the entry based on the tags.</p>};

    return $html;
}

sub _field_html {
    my $app     = MT->instance;
    my $blog    = $app->blog;
    my $blog_id = $blog->id;

    my $plugin = MT->component('RelatedItems');
    my $config = $plugin->get_config_hash( 'blog:' . $blog_id );
    my $count  = $config->{related_items_count};

    my $html =
        q{<link rel="stylesheet" href="http://localhost<mt:RelatedItemsStaticWebPath />css/ri_styles.css" />};
    $html .= q{<div class="ri_tag_div"><input class="" type="text" name="<mt:var name="field_name">" 
       id="<mt:var name="field_id">" value="<mt:Var name="field_value" escape="html">" size="40"> <label>Show preview <input name="ri_<mt:var name="field_name">_show_preview" id="ri_<mt:var name="field_name">_show_preview" type="checkbox" value="show_preview" checked="checked" /></label></div>};
    $html .= q{<script type="text/javascript">
$(function(){
    var field_name = '<mt:var name="field_name">';
    var preview_switch_id = '#ri_' + field_name + '_show_preview';
    var preview_id = '#ri_' + field_name + '_preview';
    var type="<mt:var name='options' />";
    var blog_id='<mt:var name="blog_id" />';

    if (typeof(RI_SCRIPT_LOADED) == "undefined" ) {
        $.getScript("<mt:RelatedItemsStaticWebPath />js/ri_field.js", function(){
            setup_ri_field ( field_name, preview_switch_id, preview_id, type, blog_id );
        });
    } else {
        setup_ri_field ( field_name, preview_switch_id, preview_id, type, blog_id);
    }
});
};

    $html .=
        "var blog_id = $blog_id; var <mt:var name='field_name'>_type = '<mt:var name='options' />'; var count = '$count'; </script>";
    $html .= q{<div class="field-header"></div>};

    $html .= q{<fieldset>
<legend>Related Items Preview</legend>
<h2>Related <mt:var name="options"> items:</h2>
<div id="ri_<mt:var name="field_id" />_preview">
</div>
</fieldset>
};
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
        MT->log(" count : $count ");
    }

    return $app->errtrans(" Blog_id is required . ")
        unless defined( $app->param('blog_id') );

    # what kind of object are we listing?
    return $app->errtrans(" Type parameter is required . ")
        unless $app->param('type');

    return $app->errtrans(" Tags parameter is required . ")
        unless $app->param('tags');

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
    $ctx->stash( 'count',         $count ) if defined $count;

    my $vars = $ctx->{__stash}{vars} ||= {};
    $vars->{blogid} = $blog_id;
    $vars->{tags}   = $tag_var;
    $vars->{count}  = $count;
    $vars->{type}   = $type;

    my $tmpl_class = $app->model('template');

    my $tmpl = $plugin->load_tmpl($type_template);
    return $app->errtrans( 'Error loading template: [_1]', $type_template )
        unless $tmpl;

    $tmpl->context($ctx);

    return $tmpl;
}

1;
