use Mojo::Base -strict;
BEGIN { $ENV{MOJO_MODE} = 'testing' }

use Test::More;
use Mojolicious::Lite;
use Mojolicious::Plugin::Images::Test ':all';
use Imager;
use IO::All 'tmpdir';
use Mojo::Util 'monkey_patch';

my $tmpdir = io()->tmpdir . "/images";

# namespace
@MyApp::ISA = ('Mojolicious::Lite');
my $app = MyApp::->new;
$app->plugin('Images', {foo => {}});
my $c   = $app->build_controller;
my $foo = $c->images->foo;
is $foo->namespace, undef;

@MyApp::ISA = ('Mojolicious');
$app        = MyApp::->new;
$app->plugin('Images', {foo => {}});
$c   = $app->build_controller;
$foo = $c->images->foo;
is $foo->namespace, 'MyApp';

@MyApp::Trans::ISA = ('Mojolicious::Plugin::Images::Transformer');
@Outer::Trans::ISA = ('Mojolicious::Plugin::Images::Transformer');

monkey_patch('MyApp::Trans',
  trans1000 => sub { shift->image->scale(xpixels => 1000) });
monkey_patch('Outer::Trans',
  trans99 => sub { shift->image->scale(xpixels => 99) });

$app = MyApp::->new();
$app->plugin(
  'Images' => {
    img1000 => {transform => 'trans#trans1000', dir => $tmpdir},
    img99   => {
      transform => 'outer-trans#trans99',
      dir       => $tmpdir,
      namespace => '',
      from      => 'img1000'
    },
    img199 => {
      transform => sub { shift->image->scale(xpixels => 199) },
      dir       => $tmpdir,
      from      => 'img1000'
    },
    img200x10 => {
      transform => [scale => {xpixels => 200}, crop => {height => 10}],
      dir       => $tmpdir,
      from      => 'img1000'
    },

  }
);
$c = $app->build_controller;
my $id = uniq_id;

$c->images->img1000->upload($id, test_upload);
is $c->images->img1000->read($id)->getwidth,    1000, "right width";
is $c->images->img99->read($id)->getwidth,      99,   "right width";
is $c->images->img200x10->read($id)->getwidth,  200,  "right width";
is $c->images->img200x10->read($id)->getheight, 10,   "right height";

done_testing;

