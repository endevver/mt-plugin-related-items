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

1;
