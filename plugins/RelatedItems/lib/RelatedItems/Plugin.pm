package RelatedItems::Plugin;

use RelatedItems::RelatedItemsField;

use strict;
use warnings;

sub load_customfield_types {
    my $customfield_types = {
        related_items_tags => {
            label             => 'Related Items Tags',
            column_def        => 'vchar',
            order             => 301,
            no_default        => 1,
            options_delimiter => '',
            options_field     => sub { RelatedItems::RelatedItemsField::_options_field(); },
            field_html        => sub { RelatedItems::RelatedItemsField::_field_html(); },
        },
    };
}

sub update_template {
    MT->log('update template');

    # This is responsible for loading jQuery in the head of the site.
    my ( $cb, $app, $template ) = @_;

    # Check if jQuery has already been loaded. If it has, just skip this.
    unless ( $$template =~ m/jquery/ ) {

        # Include jQuery as part of the js_include, used on the
        # include/header.tmpl, which is used on all pages.
        my $old = q{<mt:setvarblock name="js_include" append="1">};
        my $new = <<'END';
    <script id="ri_jquery" type="text/javascript" src="<mt:StaticWebPath>jquery/jquery.js"></script>
END
        $$template =~ s/$old/$old$new/;
    }

    # Check if ri_field has already been loaded. If it has, just skip this.
    unless ( $$template =~ m/ri_field/ ) {
        my $old = q{<mt:setvarblock name="js_include" append="1">};
        my $new = <<'END';
    <script id="ri_field" type="text/javascript" src="<mt:PluginStaticWebPath component='relateditems'>js/ri_field.js"></script>
END
        $$template =~ s/$old/$old$new/;
    }

}

1;
