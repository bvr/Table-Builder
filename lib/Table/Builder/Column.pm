
package Table::Builder::Column;
# ABSTRACT: Column definition for a table

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

=head1 SYNOPSIS

    use Table::Builder;

    my $tb = Table::Builder->new(cols => [      # note the arrayref
        col_accessor => {
            align => 'center',
            label => 'Column Label',
            formatter => sub { sprintf "%.2f", $_ },
            ...
        },
        ...
    ]);

=head1 DESCRIPTION

Contains settings for specific column. Except for attributes specified below,
all other settings is passed to L<Moose> attribute definition in row class.
This allow to define validation, coercions, defaults, lazy calculation, etc.

=attr name

Required. Name of column accessor in the row class

=attr label

Textual label for column header. By default same as B<name>

=attr hidden

Boolean, when true, column can contain data, but is not printed.
Visible by default.

=attr align

    align => 'left'

Alignment of column. Can be one of B<left>, B<right> or B<center>.
Default is B<left> alignment.

=attr formatter

    formatter => sub { sprintf "%.2f", $_ }

Code to format column contents, supplied in C<$_> variable.

=attr inferred

    inferred => sub { my $self = shift; return $self->other_column * 2 }

Code to calculate column value. It is called with row object and
return column value.

=head1 SEE ALSO

L<Table::Builder>

=cut
