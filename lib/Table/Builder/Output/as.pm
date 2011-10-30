
package Table::Builder::Output::as;
# ABSTRACT: output a table using ActiveState::Table
use Moose;
extends 'Table::Builder::Output';

use ActiveState::Table;

has box_chars => (is => 'ro', default => 'unicode');

sub render_data {
    my ($self, $builder, $fh) = @_;

    binmode($fh, ':utf8');
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

__PACKAGE__->meta->make_immutable();

1;

