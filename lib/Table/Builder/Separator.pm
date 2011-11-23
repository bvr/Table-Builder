
package Table::Builder::Separator;
# ABSTRACT: Separator in a table

use Moose;
use MooseX::Types::Moose qw(Bool);

has double => (is => 'ro', isa => Bool, default => 0);

__PACKAGE__->meta->make_immutable();

1;

