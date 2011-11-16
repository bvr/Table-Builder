
package Table::Builder::Output::ascii;
# ABSTRACT: output a table using ascii characters
use Moose;
extends 'Table::Builder::Output';

use utf8;
use List::Util      qw(max);
use List::MoreUtils qw(part);

has header    => (is => 'ro', default => 1);
# has box_chars => (is => 'ro', default => sub { _matricize(<<'---') });
#     .-+.
#     | ||
#     +=++
#     +-++
#     '-+'
# ---

# TODO: rather list of options
has box_chars => (is => 'ro', default => sub { _matricize(<<'---') });
    ┌─┬┐
    │ ││
    ╞═╪╡
    ├─┼┤
    └─┴┘
---

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
        $self->box_chars->[$type][3],
        "\n";
}

sub render_data {
    my ($self, $builder, $fh) = @_;

    # TODO: should be only for unicode boxes
    binmode($fh, ':utf8');

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
    $self->_print_boxed_line($fh, 0, map { $self->box_chars->[0][1] x ($_+2) } @max_width);

    for my $er (@$expanded_rows) {
        my ($row, @part_lines) = @$er;

        # normal row
        for my $pl (@part_lines) {
            # TODO: alignment
            $self->_print_boxed_line($fh, 1, map { sprintf " %-*s ", $max_width[$_], $pl->[$_] } 0..$#max_width);
        }

        # separators or line after header
        if($row->isa('Table::Builder::Separator') || $row->isa('Table::Builder')) {
            my $box_type = $row->can('double') ? ($row->double ? 2 : 3) : 3;
            $self->_print_boxed_line($fh, $box_type, map { $self->box_chars->[$box_type][1] x ($_+2) } @max_width);
        }
    }

    # bottom delimiter line
    $self->_print_boxed_line($fh, 4, map { $self->box_chars->[4][1] x ($_+2) } @max_width);
}

# convert lines and characters in a string to 2D arrayref
sub _matricize {
    my $block = shift;
    [ map { s/\A\s+//; s/\s+\z//; [ split // ] } split /\n/, $block ];
}

1;

