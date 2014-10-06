use Mojo::Base -strict;
use Test::More;
use Mojolicious;
use Mojolicious::Plugin::Images::Test ':all';
use Mojolicious::Plugin::Images::Util ':all';

my $options = {first => {}};

my $app = Mojolicious->new;
$app->plugin('Images', $options);
my $c = $app->build_controller;

my $first = $c->images->first;

# security for dummies
foreach my $meth (qw(url canonpath exists read)) {
  is eval { $first->$meth('../ff') }, undef, "right death on $meth";
  like $@, qr/insecure id/, "right error";
}

is eval { $first->write('../ff', test_image) }, undef, "right death on write";
like $@, qr/insecure id/, "right error";
is eval { $first->upload('../ff', test_upload) }, undef,
  "right death on upload";
like $@, qr/insecure id/, "right error";


# dir is root /
foreach my $dir (('/', $app->home, '', undef)) {
  $first->dir($dir);
  foreach my $meth (qw(canonpath exists read)) {
    is eval { $first->$meth('ff'); 1 }, undef, "died on insecure $meth";
    like $@, qr/insecure dir/, "right error";
  }
  is eval { $first->write('ff', test_image); 1 }, undef, "right death";
  like $@, qr/insecure dir/, "right error";
  is eval { $first->upload('ff', test_upload); 1 }, undef, "right death";
  like $@, qr/insecure dir/, "right error";
}

# expand static
my $paths    = $app->static->paths;
my $pristine = [@{$paths}];

is eval { expand_static('/images', '/images', $app); 1 }, undef, "right death";
like $@, qr/insecure dir/, "right error";
is_deeply $paths, $pristine;

is eval { expand_static('/', '', $app); 1 }, undef, "right death";
like $@, qr/insecure dir/, "right error";
is_deeply $paths, $pristine;

is eval { expand_static($app->home, '/', $app); 1 }, undef, "right death";
like $@, qr/insecure dir/, "right error";
is_deeply $paths, $pristine;
done_testing;
