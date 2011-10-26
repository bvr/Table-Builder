
package Table::Builder::Output::as;
# ABSTRACT: output a table using ActiveState::Table
use Moose;

use ActiveState::Table;

sub render {
    my ($self, $builder) = @_;

    my $table = ActiveState::Table->new;
    my @columns = $builder->visible_col_names;

    $table->add_field($_) for @columns;

    for my $row ($builder->rows) {
        if($row->isa('Table::Builder::Separator')) {
            $table->add_sep;
        }
        else {
            my %items = ();
            @items{@columns} = map { $row->$_() } @columns;

            $table->add_row({ %items });
        }
    }

    my %align = map { $_->name => $_->align } $builder->visible_cols;
    $table->as_box(show_trailer => 0, align => { %align }, box_chars=>'unicode');
}


__PACKAGE__->meta->make_immutable();

1;

