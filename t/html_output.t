
use Test::More;

use Table::Builder;
use List::Util qw(sum);

my $table = Table::Builder->new(cols => [ 'A', 'B', 'C' ]);

for my $i (1..3) {
    $table->add_row($i, $i*2, $i*4);
}
$table->add_sep;
$table->add_summary_row((sub { sum @_ }) x 3);

my $expected = <<END;
<html>
<head>
  <style>
    table.builder { border-collapse: collapse; }
    table.builder td, table.builder th { border: solid 1px #000000; padding: 2px 5px; text-align: left; }
    table.builder th { border-bottom: solid 2px #000000; }
    tr.separated td { border-top: solid 2px #000000 }
  </style>
</head>
<body>
<table class="builder">
  <tr>
    <th class="A">A</th>
    <th class="B">B</th>
    <th class="C">C</th>
  </tr>
  <tr>
    <td class="A">1</td>
    <td class="B">2</td>
    <td class="C">4</td>
  </tr>
  <tr>
    <td class="A">2</td>
    <td class="B">4</td>
    <td class="C">8</td>
  </tr>
  <tr>
    <td class="A">3</td>
    <td class="B">6</td>
    <td class="C">12</td>
  </tr>
  <tr class="separated">
    <td class="A">6</td>
    <td class="B">12</td>
    <td class="C">24</td>
  </tr>
</table>
</body>
</html>
END

is $table->render_as('html', full_page => 1), $expected, 'html matches';

done_testing;
