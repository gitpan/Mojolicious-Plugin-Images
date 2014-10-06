# NAME [![Build Status](https://travis-ci.org/alexbyk/mojo-images.svg?branch=master)](https://travis-ci.org/alexbyk/mojo-images)

Mojolicious::Plugin::Images - easy and powerful image manipulation for Mojolicious

# VERSION

version 0.002

# Attention

This is the test release, it isn't available on CPAN yet. Documentation is "на отъебись dzil-а" only.
You can check out an [example](https://github.com/alexbyk/mojo-images/blob/master/examples/Resize.pl) - it is cool. 

Advices are welcome.

Production ready release and some docs will be available ASAP (or maybe wan't). Add to bookmarks - don't miss it.

# SYNOPSIS

    plugin 'Mojolicious::Plugin::Images', {
      big   => {},
      small => {
        from      => 'big',
        transform => [scale => {xpixels => 242, ypixels => 200, type => 'min'}]
      },
    };

    # then in controller save an image ridiculously simple
    $c->images->big->upload('ID', 'image_param');

That's all. This code automatically installs lazy (on demand) resizing for images and
installs valid static paths to serve images as static content. Check debug log to see
what path to provide for nginx, for example.

# DESCRIPTION

This nifty and amazing plugin helps to orginize images in your application. It provides very simple but poweful features
even without coding.
Can be used in small application to generate thumbnails and so on and
in poweful services which works a lot with images as well.

Plugin supports automaticaly calculation of static paths, on demand resizing (lazy), image protections and so on.
For example, if you'll decide to change a design, you can delete all you thumbnails and change the size. Plugin will
regenerate them when someone will need them on-the-fly.

Right now as you can see documentation is written "на отъебись" - to pass all tests only. It will be available soon if someone
will find that useful.

I've made a small but ready to run example. Check it out (see example directory)

By the way. I liked signatures feature so much, so I decided to made 5.20.0 as a depency. Sorry for that

# METHODS

## register a plugin

Registers a plugin with options. If options is omitted, plugin will try to load them from
configaration via b<plugin\_images> key

# AUTHOR

alexbyk <alexbyk@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by alexbyk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
