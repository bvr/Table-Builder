
package Table::Builder::Column;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(Bool CodeRef HashRef);

has name   => (is => 'ro', required => 1);
has align  => (is => 'ro', isa => enum([qw(left right center)]), default => 'left');
has hidden => (is => 'ro', isa => Bool, default => 0);
has label  => (is => 'ro', lazy => 1, default => sub { shift->name });

has formatter => (is => 'ro', isa => CodeRef, predicate => 'has_formatter');
has inferred  => (is => 'ro', isa => CodeRef, predicate => 'has_inferred');

has _other_options => (
    is      => 'ro',
    isa     => HashRef,
    default => sub { +{} },
);

sub BUILD {
    my ($self, $params) = @_;

    # process extra parameters that does not match attribute list
    for my $k (keys %$params) {
        $self->_other_options->{$k} = $params->{$k}
            unless $self->meta->has_attribute($k);
    }
}

sub format {
    my ($self, $data) = @_;
    local $_ = $data;
    return $self->formatter->();
}

__PACKAGE__->meta->make_immutable();

1;

