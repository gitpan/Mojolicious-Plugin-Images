use Mojo::Base -strict;
use 5.20.0;
use experimental 'signatures';

use Test::More;
use Mojolicious;
use Mojolicious::Plugin::Images::Test ':all';
use Mojo::Util 'steady_time';
use Imager;
use IO::All 'tmpdir';

my $tmpdir  = io()->tmpdir;
my $options = {
  origin => {
    dir        => "$tmpdir/images/media/",
    suffix     => '-origin',
    url_prefix => '/media',
  },
  dest => {
    dir        => "$tmpdir/images/media/",
    suffix     => '-dest',
    url_prefix => '/media',
    from       => 'origin',
    transform  => sub($t) {
      $t->image->scale(xpixels => 69, ypixels => 69, type => 'nonprop');
    }
  }
};

my $app = Mojolicious->new;
$app->plugin('Images', $options);
my $c      = $app->build_controller;
my $origin = $c->images->origin;
my $dest   = $c->images->dest;

# without form Origin, with: Dest
isa_ok $origin, 'Mojolicious::Plugin::Images::Service::Origin', "Right class";
isa_ok $dest,   'Mojolicious::Plugin::Images::Service::Dest',   "Right class";

my $id   = uniq_id;
my $path = $origin->canonpath($id);

is $path, "$tmpdir/images/media/$id-origin.jpg", "right path";
ok !$origin->exists($id), "not exists yet";

# origin: bad image
my $upload
  = Mojo::Upload->new(asset => Mojo::Asset::Memory->new->add_chunk('fff'));
die "bad upload " unless $upload->slurp eq 'fff';
ok !eval { $origin->upload($id, $upload) }, "bad image";
ok !$origin->exists($id), "not exists yet";
ok !$origin->read($id),   "read returned false";

# origin: good from Mojo::Upload
$upload = test_upload(123, 456);
$origin->upload($id, $upload);
ok $origin->exists($id),   "already exists";
isa_ok $origin->read($id), 'Imager', 'Right class';
is $origin->url($id),      "/media/$id-origin.jpg";

my $img = $origin->read($id);
is $img->getwidth,  123, "right width";
is $img->getheight, 456, "right height";

# dest: before sync
ok !$dest->exists($id), "not exists yet";

# dest: after sync
isa_ok my $sync = $dest->sync($id), 'Imager', 'synced correctly';

is $sync->getwidth,  '69', "right width of sync result";
is $sync->getheight, '69', "right height of sync result";
ok $dest->exists($id),    "exists after sync";
isa_ok $dest->read($id),  'Imager', 'Right class';
is $dest->canonpath($id), "$tmpdir/images/media/$id-dest.jpg", "right path";

# dest: read method call sync
$id = uniq_id;
$origin->upload($id, test_upload);
ok $dest->read($id),   "read method also syncronized";
ok $dest->exists($id), "exists after read";

is $dest->read($id)->getwidth,  '69', "right width";
is $dest->read($id)->getheight, '69', "right height";

# origin: good from Controller by name
$id = uniq_id;
$origin->controller(test_controller(333, 444));
$origin->upload($id, 'image');
ok $origin->exists($id),   "already exists";
isa_ok $origin->read($id), 'Imager', 'Right class';
is $origin->url($id),      "/media/$id-origin.jpg";

my $img = $origin->read($id);
is $img->getwidth,  333, "right width";
is $img->getheight, 444, "right height";
done_testing;


