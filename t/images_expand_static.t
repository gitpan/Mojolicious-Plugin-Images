use Mojo::Base -strict;
BEGIN { $ENV{MOJO_MODE} = 'testing' }

use Test::More;
use Mojolicious;
use Mojolicious::Plugin::Images::Util ':all';

my $app      = Mojolicious->new;
my $paths    = $app->static->paths;
my $pristine = [@{$app->static->paths}];
my $home     = $app->home;

expand_static('public/images', 'images', $app);
is_deeply $paths, $pristine, "Nothing changed yet";

# my/
expand_static('my/images', '/images', $app);
is_deeply $paths, $pristine = [@$pristine, "$home/my"], "Path added";

# more time
expand_static('my/images', '/images', $app);
is_deeply $paths, $pristine, "No duplicates";

# no static_path
expand_static('/foo/bar', '/images', $app);
is_deeply $paths, $pristine, "Nothing changed";

# /absolute dir
expand_static('/my/images', '/images', $app);
is_deeply $paths, $pristine = [@$pristine, "/my"], "Root path added";

expand_static('/second/photo', undef, $app);
is_deeply $paths, $pristine, "Hidden images don't affect paths";

expand_static('/second/photo', '', $app);
is_deeply $paths, $pristine = [@$pristine, '/second/photo'],
  "Added with url prefix not undefined";

done_testing;
