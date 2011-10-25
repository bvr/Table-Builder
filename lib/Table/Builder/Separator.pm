
package Table::Builder::Separator;
use Moose;
use MooseX::Types::Moose qw(Bool);

extends 'Table::Builder::Row';

has double => (is => 'ro', isa => Bool, default => 0);

__PACKAGE__->meta->make_immutable();

1;

