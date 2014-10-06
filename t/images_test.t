use Mojo::Base -base;
use Test::More;
use Mojolicious::Plugin::Images::Test ':all';

my $img = test_image(400, 200);
is $img->getwidth,  400, "right width";
is $img->getheight, 200, "right height";

$img = test_image();
ok $img->getwidth,  "right default width";
ok $img->getheight, "right default height";

$img = Imager::->new(data => test_upload(400, 200)->slurp);
is $img->getwidth,  400, "right width";
is $img->getheight, 200, "right height";

$img = Imager::->new(data => test_upload()->slurp);
ok $img->getwidth,  "right default width";
ok $img->getheight, "right default height";


$img = Imager::->new(
  data => test_controller(400, 200)->req->upload('image')->slurp);
is $img->getwidth,  400, "right width";
is $img->getheight, 200, "right height";

$img = Imager::->new(
  data => test_controller(400, 200, 'myimage')->req->upload('myimage')->slurp);
is $img->getwidth,  400, "right width";
is $img->getheight, 200, "right height";

$img = Imager::->new(data => test_controller()->req->upload('image')->slurp);
ok $img->getwidth,  "right default width";
ok $img->getheight, "right default height";


done_testing;
