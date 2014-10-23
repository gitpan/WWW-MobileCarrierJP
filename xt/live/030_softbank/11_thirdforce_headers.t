use strict;
use warnings;
use Test::More;
use LWP::Online ":skip_all";
use WWW::MobileCarrierJP::Softbank::HTTPHeader;

my $rows = WWW::MobileCarrierJP::Softbank::HTTPHeader->scrape();

my @cases = (
    {
        'model'            => '831P',
        'x-jphone-color'   => 'C262144',
        'x-jphone-display' => '240*427',
        'x-jphone-name'    => '831P',
        'x-jphone-smaf'    => '40/pcm',
    },
    {
        'model'            => '930CA',
        'x-jphone-color'   => 'C262144',
        'x-jphone-display' => '480*854',
        'x-jphone-name'    => '930CA',
        'x-jphone-smaf'    => '128/pcm',
    },
    {
        'model'            => '830SH for Biz',
        'x-jphone-color'   => 'C262144',
        'x-jphone-display' => '240*320',
        'x-jphone-name'    => '830SHe',
        'x-jphone-smaf'    => '40/pcm/grf/rs',
    },
    {
        'model'            => 'DM001SH',
        'x-jphone-color'   => 'C262144',
        'x-jphone-display' => '240*400',
        'x-jphone-name'    => 'DM001SH',
        'x-jphone-smaf'    => '40/pcm/grf/rs',
    },
    {
        'model'            => '820SC',
        'x-jphone-name'    => '820SC',
        'x-jphone-color'   => 'C262144',
        'x-jphone-display' => '240*320',
        'x-jphone-smaf'    => '64/pcm',
    },
    {
        'model'            => '706SC',
        'x-jphone-name'    => '706SC',
        'x-jphone-color'   => 'C262144',
        'x-jphone-display' => '240*320',
        'x-jphone-smaf'    => '64/pcm',
    },
);

plan tests => 2*@cases;

for my $expected (@cases) {
    my ($got, ) = grep { $expected->{model} eq $_->{model} } @$rows;
    ok $got, "got $expected->{model}";
    is_deeply $got, $expected;
}

