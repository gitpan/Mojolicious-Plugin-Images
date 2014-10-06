package Mojolicious::Plugin::Images::Service;
use Mojo::Base -base;
use 5.20.0;
use experimental 'signatures';
use IO::All;
use Imager;
use Mojo::URL;
use Mojo::Path;
use Mojolicious::Plugin::Images::Util ':all';
use Mojolicious::Plugin::Images::Transformer;
use Mojo::Util 'camelize';

has [qw(namespace url_prefix ext dir suffix write_options read_options)];
has 'transform';
has 'controller';

sub url($self, $id) {
  my $fname
    = check_id($id) . $self->suffix . ($self->ext ? '.' . $self->ext : '');
  my $fpath = Mojo::Path->new($fname)->leading_slash(0);
  my $url   = Mojo::URL->new($self->url_prefix);
  $url->path($url->path->trailing_slash(1)->merge($fpath)->canonicalize);
  $url;
}

sub canonpath($self, $id) {
  $id = check_id($id);
  my $fname = $id . $self->suffix . ($self->ext ? '.' . $self->ext : '');
  io->catfile(check_dir($self->dir, $self->controller->app), $fname)
    ->canonpath;
}

sub exists ($self, $id) {
  io($self->canonpath($id))->exists;
}

sub read ($self, $id) {
  Imager::->new(
    file => $self->canonpath(check_id($id)),
    %{$self->read_options || {}}
  );
}


sub _trans($self, $id, $img) {
  my $trans = $self->transform;
  my $new;
  my %args = (
    service    => $self,
    id         => $id,
    controller => $self->controller,
    image      => $img,
  );

  if (ref $trans eq 'CODE') {
    plugin_log($self->controller->app, "Transformation to cb with id $id");
    $new = $trans->(Mojolicious::Plugin::Images::Transformer->new(%args));
  }

  elsif (ref $trans eq 'ARRAY') {
    $new = $img;
    my @arr = @$trans;
    while (@arr) {
      my ($act, $args) = (shift @arr, shift @arr);
      $new = $new->$act(%$args);
    }
  }

  elsif ($trans && $trans =~ /^([\w\-:]+)\#([\w]+)$/) {
    my ($class, $action) = (camelize($1), $2);
    $class = $self->namespace . "::$class" if $self->namespace;
    plugin_log($self->controller->app,
      "Transformation to class $class and action $action with id $id");
    $new = $class->new(%args)->$action;
  }

  else {
    $new = $img;
  }
  return $new;
}

sub write($self, $id, $img) {
  my $canonpath = $self->canonpath($id);
  my $dir       = io->file($canonpath)->filepath;
  my $new       = _trans($self, $id, $img);

  io->dir($dir)->mkpath unless io->dir($dir)->exists;
  $new->write(file => $canonpath, %{$self->write_options || {}})
    or die Imager::->errstr;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Mojolicious::Plugin::Images::Service

=head1 VERSION

version 0.001

=head1 SYNOPSIS

  my $service = $c->helper->service_by_moniker;

=head1 DESCRIPTION

Base class for service objects (helpers).

=head1 ATTRIBUTES

=head2 namespace

=head2 url_prefix
Url prefix. Used to atomatically calculate static path. i</images> by defaults

=head2 ext

=head2 dir
Directory of images, i<public/images> by default

=head2 suffix
suffix, a moniker by default

=head2 write_options
write options for Imager

=head2 read_options
read options for Imager

=head2 transform
Transformation

  # transform to clousure
  sub { my $t = shift; return $t->image->scale(xpixels => 100) };

  # transform to {namespace}::Trans::action
  trans#action
  
  # perfom a couple of transformations
  [scale => {xpixels => 100}, crop => {width => 100}];

For the subroutines an object L<Mojolicious::Plugin::Images::Transformer> will be passed.
Must return an Imager object

=head2 controller

Documentation will be available soon

=head1 METHODS

=head2 write ($self, $id, $img) 

writes an image

=head2 url ($self, $id) 

returns url of an image

=head2 canonpath ($self, $id) 

returns a full normalized fs path of an image

=head2 exists ($self, $id)

returns true if an image with given id exists

=head2 read ($self, $id)

reads an image and returns an Imager object

=head1 AUTHOR

alexbyk <alexbyk@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by alexbyk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
