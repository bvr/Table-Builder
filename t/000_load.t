#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Table::Builder');
    use_ok('Table::Builder::Column');
    use_ok('Table::Builder::Output');
    use_ok('Table::Builder::Row');
    use_ok('Table::Builder::Separator');
    use_ok('Table::Builder::SummaryRow');
    use_ok('Table::Builder::Types');
}

done_testing;
