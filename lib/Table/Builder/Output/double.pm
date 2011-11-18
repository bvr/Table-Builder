
package Table::Builder::Output::double;
# ABSTRACT: output a table using unicode double box characters
use Moose;
use utf8;

extends 'Table::Builder::Output::unicode';

has '+box_chars' => (is => 'ro', default => sub { [
    [ "╔═", "═", "═╤═", "═╗\n" ],
    [ "║ ", " ", " │ ", " ║\n" ],
    [ "╠═", "═", "═╪═", "═╣\n" ],
    [ "╟─", "─", "─┼─", "─╢\n" ],
    [ "╚═", "═", "═╧═", "═╝\n" ],
] });

sub _header_sep { 2 }

__PACKAGE__->meta->make_immutable();

1;

