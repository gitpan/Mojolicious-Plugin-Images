package Mojolicious::Plugin::Images::Service::Origin;
use Mojo::Base 'Mojolicious::Plugin::Images::Service';
use 5.20.0;
use experimental 'signatures';
use Imager;

sub upload ($self, $id, $upload) {
  $upload = $self->controller->req->upload($upload) unless ref $upload;
  my $img = Imager::->new(data => $upload->slurp) or die Imager::->errstr;
  $self->write($id, $img);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Mojolicious::Plugin::Images::Service::Origin

=head1 VERSION

version 0.004

=head1 SYNOPSIS

  my $origin = $c->images->origin;

=head1 DESCRIPTION

A service for images that are origins of others and can be written from uploads. 
Inherits all objects from L<Mojolicious::Plugin::Images::Service> and implements the following new ones

=head1 ATTRIBUTES

=head2 from

A moniker to the parent object

=head1 METHODS

=head2 upload ($self, $id, $upload_or_name) 

Save image from L<Mojo::Upload> object or finds an upload in the controller

  $img = $origin->upload('image');
  $img = $origin->upload($controller->req->upload('image'));

=head2 read ($self, $id) 

Reads an object and tries to syncronize it if not exists yet

=head1 AUTHOR

alexbyk <alexbyk@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by alexbyk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
