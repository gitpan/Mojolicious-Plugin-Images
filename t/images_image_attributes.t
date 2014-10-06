use Mojo::Base -strict;
use Test::More;
use Mojolicious;
use Mojolicious::Plugin::Images::Test ':all';
use Mojolicious::Plugin::Images::Util ':all';
use IO::All 'tmpdir';

my $tmp_dir = io->tmpdir . "/images";
my ($r_cb_count, $w_cb_count);
my $options = {
  first => {},
  second =>
    {dir => $tmp_dir, write_options => {png_title => 'Foo', type => 'png',}},
  third => {from => 'second', dir => $tmp_dir,},
};

my $app = Mojolicious->new;
$app->plugin('Images', $options);
my $c = $app->build_controller;

my $first  = $c->images->first;
my $second = $c->images->second;
my $third  = $c->images->third;

# utf8
is $first->canonpath('привет'), 'public/images/привет-first.jpg', 'right url';
is $first->url('я'), '/images/%D1%8F-first.jpg';

# some wied things
is $first->url_prefix('/foo///')->url('bar//baz'),  '/foo/bar/baz-first.jpg';
is $first->url_prefix('/foo///')->url('/bar//baz'), '/foo/bar/baz-first.jpg';
is $first->url_prefix('foo')->url('bar'),           'foo/bar-first.jpg';

is $first->dir('привет/foo//')->canonpath('пока//bar//baz'),
  'привет/foo/пока/bar/baz-first.jpg';
is $first->dir('//привет/foo//')->canonpath('//пока//bar//baz'),
  '/привет/foo/пока/bar/baz-first.jpg';

is $first->dir('/привет/foo')->canonpath('//пока//bar//baz'),
  '/привет/foo/пока/bar/baz-first.jpg';

$first->url_prefix('/foo');
is $first->ext('')->url('bar'),    '/foo/bar-first';
is $first->ext('gif')->url('bar'), '/foo/bar-first.gif';

is $first->suffix('')->url('bar'),       '/foo/bar.gif';
is $first->suffix('/suf/2')->url('bar'), '/foo/bar/suf/2.gif';

# r/w options
my $id = uniq_id;
$second->upload($id, test_upload(100, 100));

# we read png, but second read will read jpeg and tag wan't be present
my $img = $third->read($id);
is $img->tags(name => 'png_title'), 'Foo';
my $img = $third->read($id);
is $img->tags(name => 'png_title'), undef;

# todo: test read options
done_testing;
