
use Test::More;
use Test::Fatal;
use Table::Builder;

my $table = Table::Builder->new(cols => [qw(a b c)]);
ok exception { $table->render_as('unknown') }, 'not found output class';

done_testing;

