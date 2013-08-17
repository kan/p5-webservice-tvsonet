use strict;
use warnings;
use utf8;
use Test::More;

use WebService::TVSonet::Program;

my $iepg = <<'END_STR';
Content-type: application/x-tv-program-info; charset=shift_jis
version: 1
station: ＮＨＫ総合
year: 2013
month: 08
date: 17
start: 09:00
end: 11:54
program-title: 第95回全国高校野球選手権大会　第10日
genre: 16
subgenre: 1

第1試合「済美」対「花巻東」　【解説】杉浦正則，【アナウンサー】星野圭介　第2試合「明徳義塾」対「大阪桐蔭」　【解説】川原崎哲也，【アナウンサー】横山哲也
END_STR

my $program = WebService::TVSonet::Program->new( iepg => $iepg );

is $program->title, '第95回全国高校野球選手権大会　第10日';
is $program->station, 'ＮＨＫ総合';
is $program->genre, 16;
is $program->subgenre, 1;
is $program->date->strftime('%Y-%m-%d'), '2013-08-17';
is $program->start->strftime('%Y-%m-%d %H:%M'), '2013-08-17 09:00';
is $program->end->strftime('%Y-%m-%d %H:%M'), '2013-08-17 11:54';

done_testing;

