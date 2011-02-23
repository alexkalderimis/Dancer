use strict;
use warnings;

use Test::More import => ['!pass'];
use Dancer::ModuleLoader;

plan skip_all => "Moose is needed for this test"
    unless Dancer::ModuleLoader->load('Moose');

require Dancer;

Dancer->import(':moose_fiendly');

ok("We survived");

done_testing();
