
package Table::Builder::Output::as;
# ABSTRACT: output a table using ActiveState::Table
use Moose;

use ActiveState::Table;

sub render {
    my ($self, $builder) = @_;

    my $table = ActiveState::Table->new;
    $table->add_field($_) for $builder->col_names;

    for my $row (@{ $builder->rows }) {
        if($row->isa('Table::Builder::Separator')) {
            $table->add_sep;
        }
        else {
            $table->add_row({ %$row });
        }
    }
    $table->as_box(show_trailer => 0, box_chars=>'unicode');
}


__PACKAGE__->meta->make_immutable();

1;

