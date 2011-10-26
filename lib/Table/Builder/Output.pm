
package Table::Builder::Output;
# ABSTRACT: Base class for output formats
use Moose;

use Scalar::Util qw(openhandle);
use Carp;

sub render_data {
    die "Internal error, the output format does not have defined the operation";
}

sub render_string {
    my ($self, $builder) = @_;

    my $out_string;
    open my $fh, '>', \$out_string;
    $self->render_file($builder, $fh);
    close $fh;

    return $out_string;
}

sub render_file {
    my ($self, $builder, $file) = @_;

    my $fh;
    if (openhandle($file)) {
        $fh = $file;
    }
    else {
        open $fh, '>', $file
            or carp "Cannot open file \"$file\" for writing: $!";
    }

    $self->render_data($builder, $fh);

    close $fh unless $fh eq $file;
}

__PACKAGE__->meta->make_immutable();

1;

