package Table::Builder;
# ABSTRACT: Generic way to build a table and output it in various formats

use Moose;
use Table::Builder::Types qw(ArrayRefOfCols);

=head1 SYNOPSIS


=cut

has cols => (
    is     => 'ro',
    isa    => ArrayRefOfCols,
    coerce => 1,
);

sub column_names {
    my ($self) = @_;

    return map { $_->name } @{ $self->cols };
}

has row_class => (
    is         => 'ro',
    isa        => 'Moose::Meta::Class',
    lazy_build => 1,
);

sub _build_row_class {
    my $self = shift;

    my $metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => ['Table::Builder::Row'],
        cache        => 1,
    );
    for my $col (@{ $self->cols }) {
        $metaclass->add_attribute($col->name => ( is => 'rw' ));
    }

    return $metaclass;
}

=attr rows

Array of rows in the table.

=cut

has rows => (
    traits  => ['Array'],
    is      => 'rw',
    isa     => 'ArrayRef[Table::Builder::Row]',
    handles => {
        list_rows => 'elements',
        _add_row  => 'push',
    },
);

__PACKAGE__->meta->make_immutable();

=method add_row

    $table->add_row('Apples', 10, 20);
    $table->add_row({ Item => 'Apples', Amount => 10, Tax => 20 });

Adds a new row into table.

=cut

sub add_row {
    my ($self, @items) = @_;

    # support either hashref or list of items
    my $data = @items == 1 && ref($items[0]) eq "HASH"
        ? $items[0]
        : { map { $self->cols->[$_]->name => $items[$_] } 0 .. $#items };

    my $row = $self->row_class->new_object($data);
    $self->_add_row($row);

    $self;  # allow chaining
}

sub add_summary_row {
    my ($self, @items) = @_;

    $self;  # allow chaining
}

sub add_sep {
    my ($self, %opt) = @_;

    $self;  # allow chaining
}

sub render_as {
    my ($self, $format, @opt) = @_;

    $self;  # allow chaining
}

1;
