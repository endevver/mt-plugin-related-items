use strict;
use warnings;

use lib 't/lib', 'lib', 'extlib';
use MT::Test qw( :cms :db :data );
use Test::More tests => 31;

use MT;

# $MT::DebugMode = 7;
use CustomFields::Field;

use RelatedItems::Tags;
use RelatedItems::RelatedItemsField;
use RelatedItems::Plugin qw(get_object_types);

require MT::Template;
require MT::Template::Context;

my $ttypes = MT->registry('object_types');

my @tclasses = RelatedItems::Plugin::get_object_types();

my $tag = 'atag';

SETUP: {
    for my $tclass (@tclasses) {
        for my $i ( 1 .. 3 ) {
            my $item = MT->model($tclass)->new();
            $item->tags($tag);
            if ( $tclass =~ /^(entry|page|as)$/ ) {
                $item->title("$tclass with tag $tag");
                $item->author_id(1);
                $item->status(2) if $item->can('status');
            }
            else {
                $item->label("$tclass with tag $tag");
            }
            $item->blog_id(1);
            $item->save;

        }
    }
}

my $ctx = MT::Template::Context->new;
ok( $ctx->handler_for('RelatedItems'), 'RelatedItems tag defined' );

my $blog = MT::Blog->load(1);

my $ri_entry = MT->model('entry')->load(1);

foreach my $tclass (@tclasses) {

    # related items field
    my $ri_field = CustomFields::Field->new();
    $ri_field->type('related_items_tags');

    my $plural   = MT->model($tclass)->class_label_plural;
    my $basename = 'related_' . lc($plural);

    $ri_field->name( 'Related ' . $tclass );
    $ri_field->basename($basename);
    $ri_field->obj_type('entry');
    $ri_field->blog_id(1);
    $ri_field->tag( 'EntryRelated' . $plural );
    $ri_field->options($tclass);
    $ri_field->save;

    my $field = CustomFields::Field->load(
        {   type     => 'related_items_tags',
            basename => 'related_' . lc($plural),
        }
    );

    ok( $field, 'created Related ' . $tclass . ' custom field' );

    my $full_basename = "field.$basename";
    $ri_entry->$full_basename($tag);
}

$ri_entry->save;

foreach my $tclass (@tclasses) {
    my $plural   = MT->model($tclass)->class_label_plural;
    my $basename = 'related_' . lc($plural);

    my $nametag = 'assetlabel';
    $nametag = 'entrytitle' if $tclass eq 'entry';
    $nametag = 'pagetitle'  if $tclass eq 'page';

    my $tmpl_text =
        "<mt:RelatedItems basename='$basename'><mt:$nametag /> [<mt:var name='num_results' />] </mt:RelatedItems>";

    tmpl_out_like(
        $tmpl_text, {},
        { blog_id => $blog->id, blog => $blog, entry => $ri_entry },
        qr/^$tclass with tag $tag/,
        "$basename, no lastn, returns $tclass objects tagged '$tag' for field value '$tag'"
    ) or diag( "Template error: " . get_tmpl_error() );

    tmpl_out_like( $tmpl_text, {}, { blog_id => $blog->id, blog => $blog, entry => $ri_entry },
        qr/[3]/, "$basename, no lastn, total results is 3" )
        or diag( "Template error: " . get_tmpl_error() );

    my $tmpl_text_2 =
        "<mt:RelatedItems basename='$basename' lastn='2'>[<mt:var name='num_results' />] </mt:RelatedItems>";

    tmpl_out_like( $tmpl_text_2, {}, { blog_id => $blog->id, blog => $blog, entry => $ri_entry },
        qr/[3]/, "$basename, lastn 2, total results is 3" )
        or diag( "Template error: " . get_tmpl_error() );

    my $tmpl_text_3 =
        "<mt:RelatedItems basename='$basename' lastn='2'><mt:var name='__counter__' /></mt:RelatedItems>";

    tmpl_out_like( $tmpl_text_3, {}, { blog_id => $blog->id, blog => $blog, entry => $ri_entry },
        qr/12/, "$basename, lastn 2, yields 2 results" )
        or diag( "Template error: " . get_tmpl_error() );

}
