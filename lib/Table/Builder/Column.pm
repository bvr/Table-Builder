
package Table::Builder::Column;
use Moose;

has name => (is => 'ro');


__PACKAGE__->meta->make_immutable();

1;

