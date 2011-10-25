
package Table::Builder::Types;

use MooseX::Types -declare => [
    qw(
        ArrayOfStr
        ArrayRefOfCols
    )
];

use MooseX::Types::Moose qw(Str ArrayRef);

use Table::Builder::Column;
use Table::Builder::Row;
use Table::Builder::Separator;

class_type 'Table::Builder::Column';

subtype ArrayOfStr,     as ArrayRef[Str];
subtype ArrayRefOfCols, as ArrayRef['Table::Builder::Column'];

coerce ArrayRefOfCols, from ArrayOfStr, via {
    [ map { Table::Builder::Column->new(name => $_) } @$_ ];
};

1;

