
package Table::Builder::Output::ascii;
# ABSTRACT: output a table using ascii characters
use Moose;
extends 'Table::Builder::Output';

use utf8;
use List::Util      qw(max);
use List::MoreUtils qw(part);

has header    => (is => 'ro', default => 1);
has box_chars => (is => 'ro', default => sub { [
    [ ".-", "-", "-+-", "-.\n" ],
    [ "| ", "|", " | ", " |\n" ],
    [ "+=", "=", "=+=", "=+\n" ],
    [ "+-", "-", "-+-", "-+\n" ],
    [ "'-", "-", "-+-", "-'\n" ],
] });

__PACKAGE__->meta->make_immutable();

sub _make_lines {
    my ($self, @columns) = @_;

    my $ncols = @columns;
    for my $i (0 .. $ncols-1) {
        my @items = split /\n/, $columns[$i];
        @columns[ map { $ncols*$_ + $i } 0..$#items ] = @items;
    }
    for my $i (0 .. (int($#columns / $ncols) + 1)  * $ncols - 1) {
        $columns[$i] = '' unless defined $columns[$i]
    }

    my $i = 0;
    return part { int($i++ / $ncols) } @columns;
}

sub expand {
    my ($self, $builder) = @_;

    my @ret = ();

    # TODO: should expand non-printable characters (tabs, etc)

    if($self->header) {
        my @labels = map { $_->label } $builder->visible_cols;
        push @ret, [ $builder, $self->_make_lines(@labels) ];
    }

    for my $row ($builder->rows) {
        my $current = [ $row ];
        push @ret, $current;

        next if $row->isa('Table::Builder::Separator');

        my @columns = map {
            my $acc  = $_->name;
            my $data = $row->$acc();
            $data = $_->format($data)
                if $_->has_formatter;
            $data
        } $builder->visible_cols;

        push @$current, $self->_make_lines(@columns);
    }

    return [ @ret ];
}

sub _print_boxed_line {
    my ($self, $fh, $type, @items) = @_;

    print {$fh}
        $self->box_chars->[$type][0],
        join($self->box_chars->[$type][2], @items),
        $self->box_chars->[$type][3];
}

sub _header_sep { 3 }

sub render_data {
    my ($self, $builder, $fh) = @_;

    my $expanded_rows = $self->expand($builder);

    # determine max_width of each column
    my @max_width = ( (0) x $builder->visible_cols );
    for my $er (@$expanded_rows) {
        for my $i (1..$#$er) {
            my $part_line = $er->[$i];
            @max_width
                = map { max($max_width[$_], length($part_line->[$_])) }
                    0 .. $#max_width;
        }
    }

    # top delimiter line
    $self->_print_boxed_line($fh, 0,
        map { $self->box_chars->[0][1] x $_ } @max_width);

    for my $er (@$expanded_rows) {
        my ($row, @part_lines) = @$er;

        # normal row
        for my $pl (@part_lines) {
            # TODO: alignment
            $self->_print_boxed_line($fh, 1,
                map { sprintf "%-*s", $max_width[$_], $pl->[$_] } 0..$#max_width);
        }

        # separators or line after header
        my $sep = 0;
        $sep = $self->_header_sep    if $row->isa('Table::Builder');
        $sep = $row->double ? 2 : 3  if $row->isa('Table::Builder::Separator');

        if($sep) {
            $self->_print_boxed_line($fh, $sep,
                map { $self->box_chars->[$sep][1] x $_ } @max_width);
        }
    }

    # bottom delimiter line
    $self->_print_boxed_line($fh, 4,
        map { $self->box_chars->[4][1] x $_ } @max_width);
}

1;

