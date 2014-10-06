#!/usr/bin/env perl
use Mojolicious::Lite;
use 5.20.0;
use experimental 'signatures';
use Imager;
my $logo = Imager::->new(data => Mojo::Loader->data(__PACKAGE__, 'logo.png'));

plugin 'Mojolicious::Plugin::Images', {
  big       => {},
  with_logo => {
    from      => 'big',
    transform => sub($t) { $t->image->compose(src => $logo) }
  },
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

get '/'    => sub($c) { $c->render('index'); };
get '/:id' => sub($c) { $c->render('result') };

app->start;


__DATA__

@@ result.html.ep
% layout 'default';

<div class="row">
  <div class="col-md-8">
    <h2>Big(original size):</h2>
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
    URL: <code><%= $c->images->small->url($id) %></code>
    <br>
    FILE: <code><%= $c->images->small->canonpath($id) %></code>
    <p>You can delete this image and refresh this page, plugin will generate it automatically for you</p>
  </div>
</div>
<div class="row">
  <div class="col-md-8">
    <h2>Big(original size with logo):</h2>
    <div class="thumbnail">
      <img src="<%= $c->images->with_logo->url($id) %>">
    </div>
  </div>
</div>
<div class="row">
  <div class="col-md-12">
      <a href="/" class="btn btn-default">Upload another one</a>
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

@@ logo.png (base64)
iVBORw0KGgoAAAANSUhEUgAAAMgAAAA8CAMAAAAUhQWjAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJ
bWFnZVJlYWR5ccllPAAAAyZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdp
bj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6
eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNS1jMDIxIDc5LjE1
NTc3MiwgMjAxNC8wMS8xMy0xOTo0NDowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJo
dHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlw
dGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAv
IiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RS
ZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpD
cmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTQgKFdpbmRvd3MpIiB4bXBNTTpJbnN0
YW5jZUlEPSJ4bXAuaWlkOjUzNEFFQkFBNENGOTExRTRCNTY1RjY2MDdEQzlGRDBBIiB4bXBNTTpE
b2N1bWVudElEPSJ4bXAuZGlkOjUzNEFFQkFCNENGOTExRTRCNTY1RjY2MDdEQzlGRDBBIj4gPHht
cE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6NTM0QUVCQTg0Q0Y5MTFF
NEI1NjVGNjYwN0RDOUZEMEEiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6NTM0QUVCQTk0Q0Y5
MTFFNEI1NjVGNjYwN0RDOUZEMEEiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94
OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz5aDTwtAAABgFBMVEX/6M7/3wDlr13/z5iT1ct0
YEr/z5vP6+dtybv+/v4DAAD/+bv/56yPclWhpaLXsYT/0Zz/xIP/0qD/zpLqdVatAh62lmzTz83/
77HxyJYqvKvsAAGji23ztIP/26T/5Jb/0JnqvwD/U+3Do3fbxJMEtWoApqX/vas7MSYAko7/0ZX/
y5j/4LtVRzb/osP/ypb/BFvkAADczb3/8d8Ao5nx1rjxz6v/vXz/4Kb/96P/zZmkN1r8zJr/z55t
E0rx8vLzAAD1+vnk2KX/25z/yIrq5eEST1b/2KxOwrL/1aAAmMLgBQX/z7YAu86z0QDvwI8At6P/
zZv/zJr74qrbTjrqNyjy0Jr+26L/25ScgGD/ypr/0pr/UWT/yJZCqZr/w4zy3sb/0Z78/PnlCwpX
iYP/1J707+f/AAD49vP/0Jz/y5L/1ZVidHv/1p7l6/Hp9fOz4Nnd8O34v7Df0Ye5wrPa3dvZHBz/
0pX82K8lDRH1imjlt5D/iYYAspv///////8H04MjAAAAgHRSTlP/////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////ADgFS2cA
AAycSURBVHjazFqNX9rWGubuwEFJKIfE2qCIp8N1NJEx1g/xlKwidNp2mwbbOsyYjW1qlTp0a3dn
nfFfv++bAKK193e3/ebNW/PhIeD75Hmf9yM08vxOJrPJl1xFMR3XNk3FbWxW7969W61ubtIlxXWV
6krqk+vX/zWw7z+78ejRoxs3bnx3EiKLeN7oqzsrc7YidndJ07LTm3ce1EZhtfYAlgkjSj239O0v
Rwjm+jks8TABAZ897/XdOcKFMCx17u4rf8W32p2VtCsMo0lyPpipITDff/bo0XchAzIK2/MplQrA
8Rxh4EIA51Vmjhu7BiEbgrhLfTABlOufPQobI7g9n1OYkn6OKAILSBm9O8cs2zYtQ1BKqOsz08fy
/duwhZbvcUNJ/z7qBWQMVj3vzhxjpuCcUcIJt1Q+jOVdyEILCbi/qe5uYVQFPwNDToRhOsK2COfU
1i2hun0sb8MEpO/4nblIoI/h0MKVTJoK06Gc65yYjFiUUtXo5L79ZSV/ECIg6LPvdUTFk574hzm5
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
YII=
