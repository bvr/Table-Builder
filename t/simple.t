
use Test::More;

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

is $table->render_as('csv'),
"Item,Count
Roman,10
Mirek,12
Josef,15
Jim,99
Total,136
", 'Expected output of CSV';

done_testing;

