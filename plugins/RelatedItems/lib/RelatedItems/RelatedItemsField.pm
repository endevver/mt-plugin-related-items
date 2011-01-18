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
       id="<mt:var name="field_id">"></div>};

    $html .= q{<div id="results"></div>};
    return $html;
}

sub ri_list_related_items {
    return "ri_list_related_items";
}

1;
