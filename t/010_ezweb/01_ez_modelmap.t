use strict;
use warnings;
use Test::More tests => 17;
use WWW::MobileCarrierJP::EZWeb::Model;

my $info = WWW::MobileCarrierJP::EZWeb::Model->scrape;
is ref($info), 'ARRAY';
ok scalar(@$info) > 30;

ok scalar( grep { $_ } map { $_->{is_color} } @$info ) > 30, 'color';
is scalar( grep { not defined $_ } map { $_->{is_color} } @$info ), 0;

cmp_ok scalar( grep { $_ } map { $_->{gif} } @$info ), '>', 30, 'gif';
is scalar( grep { not defined $_ } map { $_->{gif} } @$info ), 0;

cmp_ok scalar( grep { $_ } map { $_->{png} } @$info ), '>', 30, 'png';
is scalar( grep { not defined $_ } map { $_->{png} } @$info ), 0;

cmp_ok scalar( grep { $_ } map { $_->{jpeg} } @$info ), '>', 30, 'jpeg';
is scalar( grep { not defined $_ } map { $_->{jpeg} } @$info ), 0;

cmp_ok scalar( grep { $_ && $_ eq '2.0' } map { $_->{flash_lite} } @$info ), '>', 30, 'flash lite 2.0';
is scalar( grep { $_ && $_ eq '1.1' } map { $_->{flash_lite} } @$info ), 51, 'flash lite 1.1';
is scalar( grep { not defined $_ } map { $_->{flash_lite} } @$info ), 53, 'no flash lite';

my ($w55t, ) = grep { $_->{model_long} eq 'W55T' } @$info;
is_deeply $w55t->{display_browsing}, {width => 229, height => 245}, 'display size(browsing)';
is_deeply $w55t->{display_wallpaper}, {width => 240, height => 320}, 'display size(wallpaper)';

my ($s001, ) = grep { $_->{model_long} eq 'S001' } @$info;
ok $s001;
is_deeply $s001->{display_wallpaper}, {width => 480, height => 854}, 's001';

diag "au has @{[ scalar(@$info) ]} phones";

