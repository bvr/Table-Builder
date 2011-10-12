package Table::Builder;
use Moose;

=attr

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

sub new_with_columns {
    my @params = @_;

    # parse column spec
    # build a class for rows
    # set it up for use
}


=method add_row

    $table->add_row('Apples', 10, 20);
    $table->add_row({ Item => 'Apples', Amount => 10, Tax => 20 });

Adds a new row into table.

=cut

sub add_row {
    my ($self, @items) = @_;

    # support either hashref or list of items
}

sub add_summary_row {
    my ($self, @items) = @_;

}

sub add_sep {
    my ($self, %opt) = @_;

}

sub render_as {
    my ($self, $format, @opt) = @_;

}

1;
