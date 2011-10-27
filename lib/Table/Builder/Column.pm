
package Table::Builder::Column;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(Bool CodeRef);

has name   => (is => 'ro', required => 1);
has align  => (is => 'ro', isa => enum([qw(left right center justify)]), default => 'left');
has hidden => (is => 'ro', isa => Bool, default => 0);
has label  => (is => 'ro', lazy => 1, default => sub { shift->name });

has inferred => (is => 'ro', isa => CodeRef, predicate => 'has_inferred');

__PACKAGE__->meta->make_immutable();

1;

