
use lib 't/lib', 'lib', 'extlib';

use strict;
use warnings;

BEGIN {
    $ENV{MT_APP} = 'MT::App::Search';
}

use MT::Test qw( :app :db :data );
use Test::More tests => 1;

ok(1);
