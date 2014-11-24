package Mojolicious::Plugin::Images::Util;
use Mojo::Base -base;
use 5.20.0;
use experimental 'signatures';

use Exporter 'import';
use IO::All;

our @EXPORT_OK = (
  qw(install_route expand_static calc_static plugin_log check_dir check_id));
our %EXPORT_TAGS = (all => \@EXPORT_OK);

my $INSECURE_IDS  = $ENV{IMAGES_ALLOW_INSECURE_IDS};
my $INSECURE_DIRS = $ENV{IMAGES_ALLOW_INSECURE_DIRS};

sub check_dir($dir, $app) {
  return $dir if $INSECURE_DIRS;
  my $msg
    = "insecure dir ${\ ( $dir // 'undef' ) }, set IMAGES_ALLOW_INSECURE_DIRS env to allow it";
  die $msg if !$dir || Mojo::Path->new($app->home)->contains("$dir");
  return $dir;
}

# maybe too hard
sub check_id($id) {
  return $id if $INSECURE_IDS;
  die "insecure id $id, set IMAGES_ALLOW_INSECURE_IDS env to allow it"
    unless $id =~ /^[\ \-\w\/]+$/;
  return $id;
}

sub plugin_log($app, $tmpl, @args) {
  my $msg = sprintf($tmpl, @args);
  $app->log->debug("Mojolicious::Plugin::Images $msg");
}

sub calc_static($dir, $url_prefix, $home) {
  return unless defined $url_prefix;

  $dir = io->dir($dir)->canonpath;
  $dir = $home->rel_dir($dir) unless io->dir($dir)->is_absolute;

  my $prefix = Mojo::Path->new($url_prefix)->canonicalize->to_route;
  $prefix = Mojo::Path->new($prefix)->leading_slash(0)->trailing_slash(0);

  $dir =~ s/$prefix$// or return;

  io->dir($dir)->canonpath;
}

sub expand_static($dir, $url_prefix, $app) {
  my $static_path = calc_static($dir, $url_prefix, $app->home) or return;
  $static_path = check_dir($static_path, $app);
  my $paths = $app->static->paths;
  push @$paths, $static_path unless grep { $_ eq $static_path } @$paths;
}

# install route /$prefix/(*key)-$suffix.$ext
sub install_route($app, $moniker, $opts) {
  my $placeholder = '(*images_id)';
  my $end = $opts->{suffix} // '';
  $end .= ".${\$opts->{ext}}" if $opts->{ext};
  my $path = Mojo::Path->new($opts->{url_prefix})->leading_slash(1)
    ->trailing_slash(1)->merge("${placeholder}${end}");

  plugin_log($app, "Installing route GET $path for Images '$moniker'");
  $app->routes->get("$path")->to(cb => sub { _action(shift, $moniker) });
}

sub _action($c, $moniker) {
  my $id  = $c->stash('images_id');
  my $img = $c->images->$moniker;

  plugin_log($c->app, "Generating $moniker: $id");
  return $c->reply->static($img->url($id))
    if $img->exists($id) || $img->sync($id);

  return $c->reply->not_found;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Mojolicious::Plugin::Images::Util

=head1 VERSION

version 0.007

=head1 SYNOPSIS

  use Mojolicious::Plugin::Images::Util ':all';

=head1 DESCRIPTION

Some convinient method for plugin

=head1 FUNCTIONS

=head2 expand_static ($dir, $url_prefix, $app)

Expands application's static->paths without duplicates

=head2 calc_static ($dir, $url_prefix, $home) 

Calculate which path should be added to the static paths

=head2 install_route ($app, $moniker, $opts)

Install route for serving images.

=head2 check_id ($id)

Security checks of id. By default only i</^[\ \-\w\/]+$/> allowed

=head2 check_dir ($dir, $app)

Check directory. Allow directory outside of application parent tree (security for dummies)

=head2 plugin_log ($app, $tmpl, @args)

Prints debug log using sprintf

=head1 AUTHOR

alexbyk <alexbyk@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by alexbyk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
