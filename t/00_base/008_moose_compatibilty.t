use strict;
use warnings;
use English;

use Test::More tests => 5, import => ['!pass'];

BEGIN {
    use_ok( 'Dancer',         ':moose_fiendly' );
}

eval {
    before();
};
like( $EVAL_ERROR, qr/Undefined subroutine &main::before/,
    'Before is not imported' );

eval {
    after();
};
like( $EVAL_ERROR, qr/Undefined subroutine &main::after/,
    'After is not imported' );

eval {
    after_route sub {};
};
ok(! $EVAL_ERROR, 'After_route is imported' );

eval {
    before_route sub {};
};
ok(! $EVAL_ERROR, 'Before_route is imported' );

