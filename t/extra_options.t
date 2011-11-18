
use Test::More;
use Test::Fatal;
use Table::Builder;

my $table = Table::Builder->new(cols => [
    'Class',
    'SuperClass' => {align => 'center', default => '---'},
    'Methods'    => {align => 'right',  default => 0, isa => 'Num'},
]);
ok $table, 'table created';

$table->add_row({ Class => "Table::Builder", Methods => 5 });
ok exception {
    $table->add_row({ Class => "Table::Builder", Methods => 'XX' })
}, 'dies with validation';

my $expected = <<END;
.----------------+------------+---------.
| Class          | SuperClass | Methods |
+----------------+------------+---------+
| Table::Builder |    ---     |       5 |
'----------------+------------+---------'
END

is $table->render_as('ascii'), $expected, 'correctly printed table';

done_testing;


