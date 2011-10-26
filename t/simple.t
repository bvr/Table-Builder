
use Test::More;
use Data::Dump;

use Table::Builder;
use List::Util qw(sum);

my $table =
    Table::Builder->new(cols => ['Item', 'Count' => {align => 'right'}]);
$table
    ->add_row("Roman", 10)
    ->add_row('Mirek', 12)
    ->add_row('Josef', 15)
    ->add_sep
    ->add_row('Jim', 99)
    ->add_sep
    ;
$table->add_summary_row('Total', sub { sum(@_) });

binmode(STDOUT, ':utf8');
$table->render_as('as');

# dd $table->rows;

done_testing;

