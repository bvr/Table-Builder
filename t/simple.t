
use Test::More;

use Table::Builder;
use List::Util qw(sum);

my $table = Table::Builder->new(cols => ['Item', 'Count']);
ok $table, 'object created';

$table
    ->add_row("Roman", 10)
    ->add_row('Mirek', 12)
    ->add_row('Josef', 15)
    ->add_sep
    ->add_row('Jim', 99)
    ->add_sep
    ->add_summary_row('Total', sub { sum(@_) });

my @rows = $table->rows;
is scalar @rows,   7, 'correct number of items';
is $rows[0]->Item, 'Roman', 'first item correct';
is $rows[1]->Item, 'Mirek', 'second item correct';

my $expected = <<END;
Item,Count
Roman,10
Mirek,12
Josef,15
Jim,99
Total,136
END

is $table->render_as('csv'), $expected, 'expected output';

done_testing;

