use Mojo::Base -strict;
use Test::More;
use Mojolicious;
use Mojolicious::Plugin::Images::Util ':all';
use IO::All;


my $app  = Mojolicious->new;
my $home = $app->home;

# public
my $dir = $app->home->rel_dir('public');
my $static = calc_static('public/images', 'images/', $home);
is $static, $dir, "right dir";
ok io->dir($static)->is_absolute, "path is abs";


$static = calc_static('public/images/', 'images', $home);
is $static, $dir, "right dir";

$static = calc_static('public/images/', '/images/', $home);
is $static, $dir, "right dir";

# home
$dir = $app->home->rel_dir('/');
$static = calc_static('images/', '/images/', $home);
is $static, $dir, "right dir";

# outside (absolute dir)
$static = calc_static('/root/images/', 'images', $home);
is $static , '/root', "right abs dir";

# deeper
$dir = $app->home->rel_dir('public/foo');
$static = calc_static('public/foo/images/', '/images', $home);
is $static, $dir;


# /  means root of site
$dir = $app->home->rel_dir('public/images');
$static = calc_static('public/images', '/', $home);
is $static, $dir, "right value";

# '' != undef
$static = calc_static('public/images', '', $home);
is $static, $dir, "right value";

# is hidden (without url_prefix)
$static = calc_static('public/images', undef, $home);
is $static, undef, "right undef value for hidden";

# can't be found
$static = calc_static('public/foo/images/bar', '/images', $home);
is $static, undef, "right undef value";

$static = calc_static('foo', 'bar', $home);
is $static, undef, "right undef value";


done_testing;

