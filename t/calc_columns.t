
use Test::More;

use Table::Builder;
use List::Util qw(min max);

my $table = Table::Builder->new(cols => [
    'Constant',
    'd8' => { label => '-8', align => 'right' },
    'd9' => { label => '-9', align => 'right' },
    'Diff' => {
        align    => 'right',
        inferred => sub { my $self = shift; abs($self->d9 - $self->d8) },
    },
]);

$table
    ->add_row('const1', -2.55, -3)
    ->add_row('const2',  2.775, 3)
    ->add_row('const3',  0.645, 0.6)
    ->add_sep
    ->add_summary_row('Min', (sub { min @_  }) x 3)
    ->add_summary_row('Max', (sub { max @_  }) x 3);

my $expected = <<END;
Constant,-8,-9,Diff
const1,-2.55,-3,0.45
const2,2.775,3,0.225
const3,0.645,0.6,0.045
Min,-2.55,-3,0.045
Max,2.775,3,0.45
END

is $table->render_as('csv'), $expected, 'correctly printed table';

done_testing;


