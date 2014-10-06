#!/usr/bin/env perl
use Mojolicious::Lite;
use 5.20.0;
use experimental 'signatures';
use lib '../lib';

plugin 'Mojolicious::Plugin::Images',
  {
  big   => {},
  small => {
    from      => 'big',
    transform => [scale => {xpixels => 242, ypixels => 200, type => 'min'}]
  }
  };

post '/' => sub($c) {
  my $id = time + int(rand() * 100000);
  $c->images->big->upload($id, 'image');
  $c->redirect_to("/$id.html");
};

get '/'    => sub { shift->render('index') };
get '/:id' => sub { shift->render('result') };

app->start;

__DATA__

@@ result.html.ep
% layout 'default';

<div class="row">
  <div class="col-md-8">
    <h2>Big(original size):</h2>
    <code><%= $c->images->big->canonpath($id) %></code>
    <div class="thumbnail">
      <img src="<%= $c->images->big->url($id) %>">
    </div>
  </div>
  <div class="col-md-4">
    <h2>Small(242x222 limits):</h2>
    <code><%= $c->images->small->canonpath($id) %></code>
    <div class="thumbnail">
      <img src="<%= $c->images->small->url($id) %>">
    </div>
    <p>You can delete this image and refresh this page, plugin will generate it automatically for you</p>
  </div>
</div>
<div class="row">
  <div class="col-md-12">
      <a href="/">Upload more</a>
  </div>
</div>

 

@@ index.html.ep
% layout 'default';

<form role="form" action="/" method="POST" enctype='multipart/form-data'>
  <div class="form-group">
    <label for="exampleInputFile">Image</label>
    <input name="image" type="file" id="exampleInputFile">
    <p class="help-block">Choose image to submit</p>
  </div>
  <button type="submit" class="btn btn-default">Submit</button>
</form>


@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>

<head>
  <title>
    Mojolicious::Plugin::Images simple example
  </title>
  <style>
    body {
      padding-top: 40px;
      padding-bottom: 40px;
      background-color: #eee;
    }
  </style>
</head>

<body>
  <div class="container">
    <%=content %>
  </div>
</body>

</html>
