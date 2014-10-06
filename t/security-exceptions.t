use Mojo::Base -strict;

BEGIN {
  $ENV{MOJO_MODE}                  = 'testing';
  $ENV{IMAGES_ALLOW_INSECURE_IDS}  = 1;
  $ENV{IMAGES_ALLOW_INSECURE_DIRS} = 1;
}

use Test::More;
use IO::All;
use Mojolicious;
use Mojolicious::Plugin::Images::Test ':all';
use Mojolicious::Plugin::Images::Util ':all';

my $tmpdir  = io()->tmpdir . "/images";
my $id      = uniq_id;
my $options = {first => {dir => $tmpdir}};

my $app = Mojolicious->new;
$app->plugin('Images', $options);
my $c     = $app->build_controller;
my $first = $c->images->first;

# IDS
foreach my $meth (qw(url canonpath exists read)) {
  ok eval { $first->$meth('ff/../ff'); 1 }, "not died on insecure $meth";
}
ok eval { $first->write('ff/../ff', test_image); 1 },
  "not died on insecure write";
ok eval { $first->upload('ff/../ff', test_upload); 1 },
  "not died on insecure upload";


# dir is root /
foreach my $dir (('/', $app->home, '', undef)) {
  $first->dir($dir);
  foreach my $meth (qw(canonpath exists read)) {
    ok eval { $first->$meth('ff'); 1 }, "not dead";
  }

}

ok eval { expand_static('/images',  '/images', $app); 1 }, "not dead";
ok eval { expand_static('/',        '',        $app); 1 }, "not dead";
ok eval { expand_static($app->home, '/',       $app); 1 }, "not dead";

done_testing;
