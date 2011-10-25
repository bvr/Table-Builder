
package Table::Builder::Output::unicode;
use Moose;

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

