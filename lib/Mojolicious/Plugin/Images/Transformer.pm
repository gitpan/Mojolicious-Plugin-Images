package Mojolicious::Plugin::Images::Transformer;
use Mojo::Base -base;
use 5.20.0;
use experimental 'signatures';

has [qw(id service image controller)];
sub app ($self) { $self->controller->app }

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Mojolicious::Plugin::Images::Transformer

=head1 VERSION

version 0.002

=head1 SYNOPSIS

  Parent class for transformers

=head1 DESCRIPTION

Use this class as parent for your transformers

=head1 ATTRIBUTES

=head2 id

id of passed image

=head2 image

An Imager object

=head2 service

Helper that created an image

=head2 controller

Mojolicious controller

=head1 METHODS

=head2 app

returns application (taken from a controller)

=head1 AUTHOR

alexbyk <alexbyk@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by alexbyk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
