
use Test::More;
use Data::Printer;
use Test::Fatal;

use_ok 'Table::Builder';
use_ok 'Table::Builder::Output::ascii';

my $ao = Table::Builder::Output::ascii->new;

ok exception { $ao->_format() }, '_format: should complain';
ok ! exception { $ao->_format(text => 'aa', width => 20) }, '_format: should not complain';

my $tb = Table::Builder->new(
    cols => [
        desc => { label => "Description"},
        pace => { label => "Pace\n[min/km]",          align => 'right'  },
        time => { label => "Time\n[hh:mm:ss]\nThird", align => 'center' },
        one  => { label => "Single line",             align => 'right'  },
    ]
);
ok $tb, 'initialized';

$tb->add_row("Walk\nUp",    10, 45, 1);
$tb->add_sep();
$tb->add_row("Walk\nDown",  10, 45, 5);
$tb->add_sep(double => 1);
$tb->add_row("Simple data", 11, 46, 6);

# p $ao->expand($tb);

print $tb->render_as('ascii');
print $tb->render_as('unicode');
print $tb->render_as('double');


done_testing;

