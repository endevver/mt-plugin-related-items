use lib 't/lib', 'lib', 'extlib';

use MT::Test;
use Test::More tests => 4;

ok( MT->component('relateditems'), "RelatedItems loaded" );

# require_ok('RelatedItems::Plugin');
require_ok('RelatedItems::RelatedItemsField');
# require_ok('RelatedItems::Tags');
