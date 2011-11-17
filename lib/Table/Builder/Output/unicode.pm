
package Table::Builder::Output::unicode;
use Moose;
use utf8;

extends 'Table::Builder::Output::ascii';

has '+box_chars' => (is => 'ro', default => sub { [
    [ "┌─", "─", "─┬─", "─┐\n" ],
    [ "│ ", " ", " │ ", " │\n" ],
    [ "╞═", "═", "═╪═", "═╡\n" ],
    [ "├─", "─", "─┼─", "─┤\n" ],
    [ "└─", "─", "─┴─", "─┘\n" ],
] });

before render_data => sub {
    my ($self, $builder, $fh) = @_;
    binmode($fh, ':utf8');
};



=head1 Unicode box characters

┌─┬┐╔═╦╗┏━┳┓╓─╥╖╒═╤╕
│─││║ ║║┃━┃┃║─║║│═││
├─┼┤╠═╬╣┣━╋┫╟─╫╢╞═╪╡
└─┴┘╚═╩╝┗━┻┛╙─╨╜╘═╧╛

=head1 Suitable layout of output characters

╔═╤╗  ┌─┬┐  .--.
║ │║  │ ││  | ||
╠═╪╣  ╞═╪╡  +=++
╟─┼╢  ├─┼┤  +-++
╚═╧╝  └─┴┘  '--'

=cut

__PACKAGE__->meta->make_immutable();

1;

