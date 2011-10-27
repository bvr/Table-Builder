package Table::Builder;
# ABSTRACT: Generic way to build a table and output it in various formats

use Moose;
use Table::Builder::Types qw(ArrayRefOfCols);
use Try::Tiny;
use Carp;

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
        if($col->has_inferred) {
            $metaclass->add_method($col->name => sub { $col->inferred->(@_) });
        }
        else {
            $metaclass->add_attribute(
                $col->name => ( is => 'rw', %{ $col->_other_options } ),
            );
        }
    }

    return $metaclass;
}

=attr rows

Array of rows in the table.

=cut

has _rows => (
    traits   => ['Array'],
    isa      => 'ArrayRef',
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

    my $data = $self->_normalize_row(@items);
    my $row  = $self->_row_class->new_object($data);
    $self->_add_row($row);

    return $self;  # allow chaining
}

# support either hashref or list of items
sub _normalize_row {
    my ($self, @items) = @_;

    return $items[0] if @items == 1 && ref($items[0]) eq "HASH";
    return { map { $self->_cols->[$_]->name => $items[$_] } 0 .. $#items };
}

=method add_summary_row

    $table->add_summary_row('Apples', sub { sum(@_) }, 20);
    $table->add_summary_row({ Item => 'Apples', Amount => sub { sum(@_) }, Tax => 20 });

Adds a new row into table.

=cut

sub add_summary_row {
    my ($self, @items) = @_;

    my $metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [ 'Table::Builder::SummaryRow' ]
    );
    $metaclass->add_method(parent => sub { $self });

    my $data = $self->_normalize_row(@items);

    for my $key (keys %$data) {
        my $item = $data->{$key};
        my $meth = ref $item ne 'CODE'
            ? sub { $item }
            : sub {
                $item->(
                    map  { $_->$key() }
                    grep { $_->isa('Table::Builder::Row') }
                    $self->rows
                )
            };
        $metaclass->add_method($key => $meth);
    }
    $self->_add_row($metaclass->new_object());

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

=method render_as

    my $output = $table->render_as('ascii');
    $table->render_as('ascii', file => 'filename.txt');
    $table->render_as('ascii', file => $open_filehandle);

Renders table into string or file using specified output formatting class.

=cut

sub render_as {
    my ($self, $format, %opt) = @_;

    # try to load appropriate class and create renderer
    my $out_class_name;
    try {
        $out_class_name = 'Table::Builder::Output::' . $format;
        Class::MOP::load_class($out_class_name);
    }
    catch {
        warn $_;
        try {
            $out_class_name = $format;
            Class::MOP::load_class($out_class_name);
        }
        catch {
            croak "The format \"$format\" was not found";
        };
    };

    # is there an option to specify the output file
    my $output_file = delete $opt{file};

    my $renderer = $out_class_name->new(%opt);

    # output as a string
    if(defined wantarray && ! defined $output_file) {
        return $renderer->render_string($self);
    }

    croak "The output file was not specified for format \"$format\""
        unless defined $output_file;

    # output into file(handle)
    $renderer->render_file($self, $output_file);
    return $self;
}

1;
