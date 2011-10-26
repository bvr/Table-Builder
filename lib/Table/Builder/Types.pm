
package Table::Builder::Types;
use strict;

use MooseX::Types -declare => [
    qw(
        ArrayOfStr
        ArrayRefOfCols
        Align
    )
];

use MooseX::Types::Moose qw(Str ArrayRef);

use Table::Builder::Column;
use Table::Builder::Row;
use Table::Builder::Separator;

class_type 'Table::Builder::Column';

subtype ArrayRefOfCols, as ArrayRef['Table::Builder::Column'];

subtype Align, as enum([qw(left right center justify)]);

coerce ArrayRefOfCols, from ArrayRef, via {
    my @input = @$_;
    my @cols  = ();

    while(my $col_name = shift @input) {
        my %params = ();
        if(ref $input[0] eq 'HASH') {
            %params = %{ shift @input };
        }
        push @cols, Table::Builder::Column->new(name => $col_name, %params);
    }

    return [ @cols ];
};

1;

