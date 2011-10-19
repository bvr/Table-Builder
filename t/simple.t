
use Test::More;
use Data::Dump;

use Table::Builder;
use List::Util qw(sum);

my $table = Table::Builder->new(cols => [qw(Item Count)]);
$table
    ->add_row('Roman', 10)
    ->add_row('Mirek', 12)
    ->add_row('Josef', 15);
$table->add_summary_row('Total', sub { sum(map { $_->Count } @_) });

$table->render_as('ascii');

done_testing;

