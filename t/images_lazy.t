use Mojo::Base -base;
use 5.20.0;
use experimental 'signatures';

use Mojolicious::Lite;
use Test::More;
use Test::Mojo;
use Mojolicious::Plugin::Images::Test ':all';
use Imager;
use IO::All;

my $tmpdir  = io()->tmpdir;
my $options = {
  origin =>
    {dir => "$tmpdir/origin/images", suffix => '-origin', url_prefix => undef},
  dest => {
    dir       => "$tmpdir/dest/images",
    from      => 'origin',
    transform => sub($t) {
      $t->image->scale(xpixels => 69, ypixels => 69, type => 'nonprop');
    }
  },

  origin_public => {dir => "$tmpdir/origin_public/images"},
  dest_hidden   => {
    dir        => "$tmpdir/dest_hidden/images",
    from       => 'origin_public',
    url_prefix => undef
  },
  dest_public => {dir => "$tmpdir/dest_public/images", from => 'dest_hidden',},
};


my $t   = Test::Mojo->new;
my $app = app();

$app->plugin('Images', $options);

my $c      = $app->build_controller;
my $origin = $c->images->origin;
my $dest   = $c->images->dest;
my $id     = uniq_id;
$origin->upload($id, test_upload(400, 200));

# 2
ok !$c->images->dest->exists($id), "not exists yet";
$t->get_ok("/images/$id-dest.jpg")->status_is(200);
ok $c->images->dest->exists($id), "already exists";

$t->get_ok("/images/$id-origin.jpg")->status_is(404);
$t->get_ok("/images/$id-bad.jpg")->status_is(404);
$t->get_ok("/images/$id-dest.JPG")->status_is(404);
$t->get_ok("/images/$id-dest")->status_is(404);

# 3
$id = uniq_id;
my $origin_public = $c->images->origin_public;
my $dest_hidden   = $c->images->dest_hidden;
my $dest_public   = $c->images->dest_public;
$origin_public->upload($id, test_upload(222, 333));
ok $origin_public->exists($id), "origin exists";
ok !$dest_hidden->exists($id), "not exists";
ok !$dest_public->exists($id), "not exists";


$t->get_ok("/images/$id-dest_public.jpg")->status_is(200);
$t->get_ok("/images/$id-dest_hidden.jpg")->status_is(404);
ok $dest_hidden->exists($id), "hidden but exists";
my $img = Imager::->new(
  data => $t->ua->get("/images/$id-dest_public.jpg")->res->body);
is $img->getwidth,  222, "right width";
is $img->getheight, 333, "right height";


done_testing;


