package Mojolicious::Plugin::Images::Service::Dest;
use Mojo::Base 'Mojolicious::Plugin::Images::Service';
use 5.20.0;
use experimental 'signatures';

has from => sub { die "You have to define a 'from' attribute value" };

sub sync($self, $id) {
  my $from = $self->controller->images->${\$self->from};
  $self->write($id, $from->read($id));
}

sub read ($self, $id) {
  $self->SUPER::read($id) or $self->sync($id);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Mojolicious::Plugin::Images::Service::Dest

=head1 VERSION

version 0.001

=head1 SYNOPSIS

  my $small = $c->images->small;

=head1 DESCRIPTION

A service for images that depends on ::Origin or other ::Dest. Can be a source too, but can not be saved from upload
Inherits all objects from L<Mojolicious::Plugin::Images::Service> and implements the following new ones

=head1 ATTRIBUTES

=head2 from

A moniker to the parent object

=head1 METHODS

=head2 sync ($self, $id) 

Syncronize with parent service. Returns an imager object. Writes result to disk

=head2 read ($self, $id) 

Reads an object and tries to syncronize it if not exists yet

=head1 AUTHOR

alexbyk <alexbyk@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by alexbyk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
