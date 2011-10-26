
package Table::Builder::Column;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(Bool);

has name   => (is => 'ro');
has align  => (is => 'ro', isa => enum([qw(left right center justify)]), default => 'left');
has hidden => (is => 'ro', isa => Bool, default => 0);


__PACKAGE__->meta->make_immutable();

1;

