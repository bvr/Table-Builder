
use Test::More;
use Data::Printer;

use_ok 'Table::Builder';
use_ok 'Table::Builder::Output::ascii';

my $ao = Table::Builder::Output::ascii->new;
my $tb = Table::Builder->new(cols => [
    desc => { label => "Description" },
    pace => { label => "Pace\n[min/km]" },
    time => { label => "Time\n[hh:mm:ss]\nThird" },
    one  => { label => "Single line" },
]);

$tb->add_row('Walk', 10, 45);
$tb->add_sep;

p $ao->expand($tb);

done_testing;

