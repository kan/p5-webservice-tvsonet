use strict;
use warnings;
use utf8;
use Test::More;

use WebService::TVSonet;


my $service = WebService::TVSonet->new;

my ($program,) = $service->search('巨人');

ok $program;


done_testing;

