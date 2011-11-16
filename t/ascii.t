
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

$tb->add_row("Walk\nHome", 10, 45, 1);
$tb->add_sep(double => 1);
$tb->add_row("Walk\nHome", 10, 45, 5);

# p $ao->expand($tb);

print $tb->render_as('ascii');


done_testing;

