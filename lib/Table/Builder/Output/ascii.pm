
package Table::Builder::Output::ascii;
# ABSTRACT: output a table using ascii characters
use Moose;
extends 'Table::Builder::Output';

use List::Util      qw(max);
use List::MoreUtils qw(part);

has header    => (is => 'ro', default => 1);
has box_chars => (is => 'ro', default => sub { _matricize(<<'---') });
    .--.
    | ||
    +=++
    +-++
    '--'
---

__PACKAGE__->meta->make_immutable();

sub expand {
    my ($self, $builder) = @_;

    my @ret = ();

    if($self->header) {
        my @columns = map { $_->label } $builder->visible_cols;
        my $ncols = @columns;
        for my $i (0 .. $ncols-1) {
            my @items = split /\n/, $columns[$i];
            @columns[ map { $ncols*$_ + $i } 0..$#items ] = @items;
        }
        for my $i (0 .. (int($#columns / $ncols) + 1)  * $ncols - 1) {
            $columns[$i] = '' unless defined $columns[$i]
        }

        my $i = 0;
        my @parts = part { int($i++ / $ncols) } @columns;
        push @ret, [ $builder, @parts ];
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

        push @$current, [ @columns ];
    }

    return [ @ret ];
}


sub render_data {
    my ($self, $builder, $fh) = @_;

    # binmode($fh, ':utf8');




    # translate unprintable characters
    # TODO

    # determine max_width of each column


    # process each row, including header if $self->header is set
    #   format data of each row
    #   split the data on newlines and form multiple rows
    #   output each row with alignment formatting

    my $table = ActiveState::Table->new;
    my @columns = map { $_->label } $builder->visible_cols;

    $table->add_field($_) for @columns;

    for my $row ($builder->rows) {
        if($row->isa('Table::Builder::Separator')) {
            $table->add_sep;
        }
        else {
            my %items = ();
            @items{@columns} = map {
                my $acc  = $_->name;
                my $data = $row->$acc();
                $data = $_->format($data)
                    if $_->has_formatter;
                $data
            } $builder->visible_cols;

            $table->add_row({ %items });
        }
    }

    my %align = map { $_->label => $_->align } $builder->visible_cols;
    print {$fh} $table->as_box(
        show_trailer => 0,
        align        => {%align},
        box_chars    => $self->box_chars
    );
}

# convert lines and characters in a string to 2D arrayref
sub _matricize {
    my $block = shift;
    [ map { s/\A\s+//; s/\s+\z//; [ split // ] } split /\n/, $block ];
}

1;

