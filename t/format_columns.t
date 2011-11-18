
use Test::More;

use Table::Builder;
use List::Util qw(sum);

# simple formatter for test case.  In real use Number::Format's format_bytes
sub format_bytes {
    my $nn   = shift;
    my $suff = ' KMGT';
    while ($nn / 1024 >= 1) {
        $nn /= 1024;
        substr($suff,0,1) = '';
    }
    return sprintf "%.2f%s", $nn, substr($suff, $i, 1);
}

my $table = Table::Builder->new(cols => [
    'File',
    'Size' => {
        align     => 'right',
        formatter => sub { format_bytes($_) },
    },
]);

$table
    ->add_row("resul.zp", 2212319)
    ->add_row("sfbot.fs", 21102592)
    ->add_row("sfbot.rsv", 655360)
    ->add_row("etup.lg", 187)
    ->add_row("temp", 0)
    ->add_row("time.log", 10)
    ->add_sep
    ->add_summary_row('Total', sub { sum @_  });

my $expected = <<END;
.-----------+---------.
| File      |    Size |
+-----------+---------+
| resul.zp  |   2.11M |
| sfbot.fs  |  20.13M |
| sfbot.rsv | 640.00K |
| etup.lg   | 187.00  |
| temp      |   0.00  |
| time.log  |  10.00  |
+-----------+---------+
| Total     |  22.86M |
'-----------+---------'
END

is $table->render_as('ascii'), $expected, 'correctly printed table';

done_testing;


