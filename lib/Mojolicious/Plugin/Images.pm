package Mojolicious::Plugin::Images;
use Mojo::Base 'Mojolicious::Plugin';
use 5.20.0;
use experimental 'signatures';

use Mojo::Path;
use Mojolicious::Plugin::Images::Service::Dest;
use Mojolicious::Plugin::Images::Service::Origin;
use Mojolicious::Plugin::Images::Util ':all';

our $VERSION = '0.002';    # TRIAL VERSION

sub _class($from) {
  my $ns = "Mojolicious::Plugin::Images::Service";
  return $from ? "${ns}::Dest" : "${ns}::Origin";
}

sub _defaults {
  return (ext => 'jpg', dir => 'public/images', url_prefix => '/images');
}

sub register($self, $app, $options) {
  $options = {%{$app->config('plugin_images')}} unless keys %$options;

  foreach my $moniker (keys %$options) {

    # helper
    my %opts = (_defaults(), %{$options->{$moniker}});
    $opts{suffix} //= "-$moniker";
    $opts{namespace} //= ref $app unless $app->isa('Mojolicious::Lite');
    my $class = _class($opts{from});

    my $msg_attr = join(', ',
      map {"$_ => '${\( $opts{$_} // 'undef' ) }'"} sort keys %opts);

    plugin_log($app, "Creating helper images.%s(%s): {%s};",
      $moniker, $class, $msg_attr);

    $app->helper(
      "images.$moniker" => sub {
        $class->new(%opts, controller => shift);
      }
    );

    if (defined $opts{url_prefix}) {
      install_route($app, $moniker, \%opts);
      expand_static($opts{dir}, $opts{url_prefix}, $app);
    }
  }
}

1;

# ABSTRACT: easy and powerful image manipulation for Mojolicious

__END__

=pod

=encoding UTF-8

=head1 NAME

Mojolicious::Plugin::Images - easy and powerful image manipulation for Mojolicious

=head1 VERSION

version 0.002

=head1 SYNOPSIS

  plugin 'Mojolicious::Plugin::Images', {
    big   => {},
    small => {
      from      => 'big',
      transform => [scale => {xpixels => 242, ypixels => 200, type => 'min'}]
    },
  #  thumb  => {from => 'small', transform => 'myclass#action'},
  #  thumb2 => {
  #    from      => 'small',
  #    transform => sub($t) { $t->image->scale(xpixels => 200) }
  #  },
  };

  # then in controller save an image ridiculously simple
  $c->images->big->upload('ID', 'image_or_other_name');

That's all. This code automatically installs lazy (on demand) resizing for images and
install valid static paths to serve images as static content. Check debug log to see
what paths to provide for nginx, for example.

=head1 DESCRIPTION

This nifty and amazing plugin helps to orginize images in your application. It provides very simple but poweful features.
Can be used in small application with no coding (to generate thumbnails and so on) and
in poweful services which works a lot with images as well.

Plugin supports automaticaly calculation of static paths, on demand resizing (lazy), image protections and so on.
For example, if you'll decide to change a design, you can delete all you thumbnails and change the size. Plugin will
regenerate them when someone will need them on-the-fly.

Right now as you can see documentation is written "на отъебись" - to pass all tests only. It will be available soon if someone
will find that useful.

I've made a small but ready to run example. Check it out (see example directory)

By the way. I liked signatures feature so much, so I decided to made 5.20.0 as a depency. Sorry for that

=head1 METHODS

=head2 register a plugin

Registers a plugin with options. If options is omitted, plugin will try to load them from
configaration via b<plugin_images> key

=for HTML <a href="https://travis-ci.org/alexbyk/mojo-images"><img src="https://travis-ci.org/alexbyk/mojo-images.svg?branch=master"></a>

=head1 AUTHOR

alexbyk <alexbyk@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by alexbyk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
