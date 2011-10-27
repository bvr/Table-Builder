
package Table::Builder::Output::as;
# ABSTRACT: output a table using ActiveState::Table
use Moose;
extends 'Table::Builder::Output';

use ActiveState::Table;

sub render_data {
    my ($self, $builder, $fh) = @_;

    my $table = ActiveState::Table->new;
    my @columns = map { $_->label } $builder->visible_cols;

    $table->add_field($_) for @columns;

    for my $row ($builder->rows) {
        if($row->isa('Table::Builder::Separator')) {
            $table->add_sep;
        }
        else {
            my %items = ();
            @items{@columns} = map { my $acc = $_->name; $row->$acc() } $builder->visible_cols;

            $table->add_row({ %items });
        }
    }

    my %align = map { $_->label => $_->align } $builder->visible_cols;
    print {$fh} $table->as_box(
        show_trailer => 0,
        align        => {%align},
        box_chars    => 'unicode'
    );
}

__PACKAGE__->meta->make_immutable();

1;

