requires 'perl',        '5.20.0';
requires 'Mojolicious', '5.28';
requires 'IO::All',     '0';
requires 'Imager',      '0';

on test => sub {
  requires 'Test::More', '0.88';
};

on 'develop' => sub {
  requires 'Pod::Coverage::TrustPod';
  requires 'Test::Perl::Critic', '1.02';
};
