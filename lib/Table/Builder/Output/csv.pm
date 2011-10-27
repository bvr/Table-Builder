
package Table::Builder::Output::csv;
# ABSTRACT: output a table Text::CSV_XS
use Moose;
extends 'Table::Builder::Output';

use Text::CSV_XS;

sub render_data {
    my ($self, $builder, $fh) = @_;

    my $csv = Text::CSV_XS->new ({ binary => 1, eol => $/ });

    $csv->print ($fh, [map { $_->label } $builder->visible_cols ]);

    my @columns = $builder->visible_col_names;
    for my $row ($builder->rows) {
        next if $row->isa('Table::Builder::Separator');

        $csv->print($fh, [map { $row->$_() } @columns]);
    }
}

__PACKAGE__->meta->make_immutable();

1;

