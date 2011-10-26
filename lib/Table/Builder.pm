package Table::Builder;
# ABSTRACT: Generic way to build a table and output it in various formats

use Moose;
use Table::Builder::Types qw(ArrayRefOfCols);

=head1 SYNOPSIS


=cut

has _cols => (
    is       => 'ro',
    traits   => ['Array'],
    isa      => ArrayRefOfCols,
    coerce   => 1,
    required => 1,
    init_arg => 'cols',
    handles  => {cols => 'elements'},
);

sub visible_cols {
    my ($self) = @_;
    return grep { ! $_->hidden } $self->cols;
}

sub visible_col_names {
    my ($self) = @_;
    return map { $_->name } grep { ! $_->hidden } $self->cols;
}

has _row_class => (
    is      => 'ro',
    isa     => 'Moose::Meta::Class',
    lazy    => 1,
    builder => '_build_row_class',
);

sub _build_row_class {
    my $self = shift;

    my $metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => ['Table::Builder::Row'],
        cache        => 1,
    );
    for my $col ($self->cols) {
        $metaclass->add_attribute(
            $col->name => ( is => 'rw' )
            # TODO: more attributes from cols settings (isa, default, etc)
        );
    }

    return $metaclass;
}

=attr rows

Array of rows in the table.

=cut

has _rows => (
    traits   => ['Array'],
    isa      => 'ArrayRef[Table::Builder::Row]',
    init_arg => 'rows',
    default  => sub { [] },
    handles  => {
        rows     => 'elements',
        _add_row => 'push',
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
        : { map { $self->_cols->[$_]->name => $items[$_] } 0 .. $#items };

    my $row = $self->_row_class->new_object($data);
    $self->_add_row($row);

    return $self;  # allow chaining
}

sub add_summary_row {
    my ($self, @items) = @_;

    # TODO: construct summary row class

    return $self;  # allow chaining
}

=method add_sep

    $table->add_sep;
    $table->add_sep(double => 1);

Adds a separator row into table.

=cut

sub add_sep {
    my ($self, %opt) = @_;

    $self->_add_row(Table::Builder::Separator->new(%opt));

    return $self;  # allow chaining
}

sub render_as {
    my ($self, $format, @opt) = @_;

    my $out_class_name = 'Table::Builder::Output::' . $format;
    Class::MOP::load_class($out_class_name);

    $out_class_name->new(@opt)->render($self);

    return $self;  # allow chaining
}

1;
