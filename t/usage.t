
use Table::Builder;
use Number::Format qw(format_number format_bytes);

my $t = Table::Builder->new(
    cols => [
        Item => {
            isa   => 'Str',
            align => 'left',
            group => 1,     # or
        },
        Count => {
            isa    => 'Num',
            hidden => 1,
        },
        Power => {
            isa       => 'Num',
            default   => sub { shift->Count**2 },
            formatter => sub { format_number(shift->Power) },
            align     => 'right',
        },
    ],
    group_by => [ 'Item' ],
);

$t->add_row('Thing', 2);
$t->add_sep;
$t->add_row('Other', 5);
$t->add_row({ colspan => 2 }, 'A group');
$t->add_summary_row(Power => sub { $a + $b });

$t->render_as('ascii');


=head2 Features

Support for column merging
Grouping
Various output formats (at least CSV, TSV, XLS, HTML, MD, ASCII, Unicode)
Support newlines in data
Formatting per column
Alignment for column
Separators
Adding calculated row (with supplied function) like reduce
Adding calculated columns
Hidden columns for some data

=head2 Implementation

Row as a Moose class
Table::Builder as storage for items. Those can be:
 - a row object
 - a separator object
 - summary row object

=cut
