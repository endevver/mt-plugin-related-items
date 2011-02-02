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
