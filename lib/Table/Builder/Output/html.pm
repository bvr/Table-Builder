
package Table::Builder::Output::html;
# ABSTRACT: Output a HTML table
use Moose;
extends 'Table::Builder::Output';

has title       => (is => 'ro', default => '');
has table_class => (is => 'ro', default => 'builder');
has full_page   => (is => 'ro', default => 0);
has css_only    => (is => 'ro', default => 0);

sub render_data {
    my ($self, $builder, $fh) = @_;

    return $self->css($builder)
        if $self->css_only;

    if($self->full_page) {
        my $css = $self->css($builder);
        $css =~ s/^/    /gm;
        print {$fh} $self->page_start($css);
    }

    print {$fh} $self->table_start;
    print {$fh} $self->tr(0, map { $self->th($_->name, $_->label) } $builder->visible_cols );

    my $sep_next = 0;
    for my $row ($builder->rows) {
        if($row->isa('Table::Builder::Separator')) {
            $sep_next = 1;
        }
        else {
            my @tds = map {
                my $acc  = $_->name;
                my $data = $row->$acc();
                $data = $_->format($data)
                    if $_->has_formatter;
                $self->td($_->name, $data)
            } $builder->visible_cols;

            print {$fh} $self->tr($sep_next, @tds);
            $sep_next = 0;
        }
    }

    print {$fh} $self->table_end;

    if($self->full_page) {
        print {$fh} $self->page_end;
    }
}

sub css {
    my ($self, $builder) = @_;

    my $css = '';
    if($self->table_class) {
        my $cls = $self->table_class;
        $css .= "table.$cls { border-collapse: collapse; }\n";
        $css .= "table.$cls td, table.$cls th { border: solid 1px #000000; padding: 2px 5px; text-align: left; }\n";
        $css .= "table.$cls th { border-bottom: solid 2px #000000; }\n";
    }

    for my $col ($builder->visible_cols) {
        unless($col->align eq 'left') {
            $css .= "td." . $col->name . " { text-align: " . $col->align. " }\n";
        }
    }

    $css .= "tr.separated td { border-top: solid 2px #000000 }\n";

    return $css;
}

sub page_start {
    my ($self, $css) = @_;

    $css =~ s/\n$//;

    # title
    my $title = $self->title;
    $title = "\n  <title>$title</title>"
        unless $title eq '';

    return <<PAGE_START;
<html>
<head>$title
  <style>
$css
  </style>
</head>
<body>
PAGE_START
}

sub page_end {
    "</body>\n</html>\n"
}

sub table_start {
    my $self = shift;
    '<table' . ($self->table_class ? ' class="'.$self->table_class.'"' : '') . ">\n"
}

sub table_end {
    "</table>\n"
}

sub tr {
    my ($self, $sep, @items) = @_;
    "  <tr" . ($sep ? ' class="separated"' : '' ) . ">\n" . join('',@items) . "  </tr>\n"
}

sub td {
    my ($self, $col, @items) = @_;
    "    <td" . ($col ? ' class="'.$col.'"' : '') . ">".join('',@items)."</td>\n"
}

sub th {
    my ($self, $col, @items) = @_;
    "    <th" . ($col ? ' class="'.$col.'"' : '') . ">".join('',@items)."</th>\n"
}

__PACKAGE__->meta->make_immutable();

1;

