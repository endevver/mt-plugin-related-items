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

    # This is responsible for loading jQuery in the head of the site.
    my ( $cb, $app, $template ) = @_;

    # Load the Javascript to make this custom field work.
    my $old = q{<mt:setvarblock name="js_include" append="1">};
    my $new = <<'END';
    <script id="ri_jquery" type="text/javascript" src="<mt:StaticWebPath>jquery/jquery.js"></script>
    <script id="ri_field" type="text/javascript" src="<mt:PluginStaticWebPath component='relateditems'>js/ri_field.js"></script>
END
        $$template =~ s/$old/$old$new/;
}

1;
