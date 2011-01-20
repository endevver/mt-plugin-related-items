package RelatedItems::RelatedItemsField;

use strict;
use warnings;
use Data::Dumper;

sub _options_field {

    my $types = MT->registry('object_types');
    my @classes;
    foreach my $key ( keys %$types ) {
        next if $key =~ /\w+\.\w+/;    # skip subclasses
        my $class = MT->model($key);
        push @classes, $key if $class->isa('MT::Taggable');
    }
    MT->log( Dumper( \@classes ) );
    my $html = q{<select name="options">};
    for my $c (@classes) {
        $html .= "<option value='$c'>$c</option>";
    }
    $html .= q{</select>};

    $html .= q{<p class="hint">Select what kind of items should be returned to the entry based on the tags.</p>};

    return $html;
}

sub _field_html {
    MT->log('field_html');
    my $app  = MT->instance;
    my $blog = $app->blog;

    my $html =
        q{<div class="textarea-wrapper"><input class="full-width" type="text" name="<mt:var name="field_name">" 
       id="<mt:var name="field_id">" value="<mt:Var name="field_value" escape="html">"></div>};

    $html .= q{<div id="results"></div>};
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
        MT->log("count: $count");
    }

    return $app->errtrans("Blog_id is required.")
        unless $app->param('blog_id');

    # what kind of object are we listing?
    return $app->errtrans("Type parameter is required.")
        unless $app->param('type');

    return $app->errtrans("Tags parameter is required.")
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

    if ( $tag_var =~ /,/ ) {
        my @tags_input = split( ',', $app->param('tags') );
        $tag_var = join( ' OR ', @tags_input );
    }

    my $plugin     = MT->component("RelatedItems");
    my $blog_prefs = $plugin->get_config_hash("blog:$blog_id");

    my $type                  = $app->param('type');
    my $default_type_template = "ri_list_related_$type";

    require MT::Template::Context;
    my $ctx = MT::Template::Context->new;
    $ctx->stash( 'blog',          $blog );
    $ctx->stash( 'blog_id',       $blog_id );
    $ctx->stash( 'local_blog_id', $blog_id );
    $ctx->stash( 'count',         $count ) if defined $count;

    my $vars = $ctx->{__stash}{vars} ||= {};
    $vars->{this_blogid} = $blog_id;
    $vars->{tags}        = $tag_var;
    $vars->{count}       = $count;

    my $tmpl_class = $app->model('template');
    my $tmpl_module = $app->param('tmpl') || $default_type_template;

    my $tmpl = $tmpl_class->load(
        {

            # blog_id => $blog_id,
            identifier => $tmpl_module
        },
    );
    return $app->errtrans( 'Error loading template: [_1]', $tmpl_module )
        unless $tmpl;

    $tmpl->context($ctx);

    return $tmpl;
}

1;
