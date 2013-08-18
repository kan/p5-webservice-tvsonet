package WebService::TVSonet;
use Mouse;
use utf8;

use URI;
use Furl;
use XML::RSS;

use WebService::TVSonet::Program;

our $VERSION = "0.02";

has furl => (
    is => 'ro',
    isa => 'Furl',
    lazy => 1,
    default => sub {
        Furl->new(
            agent => "WebService::TVSonet/$VERSION",
            timeout => 10,
        );
    },
);

has rss_uri => (
    is => 'rw',
    isa => 'URI',
    lazy => 1,
    default => sub {
        URI->new('http://tv.so-net.ne.jp/rss/schedulesBySearch.action');
    },
);

no Mouse;
__PACKAGE__->meta->make_immutable;

sub search {
    my $self = shift;

    my $params;
    if (scalar(@_) == 1) {
        if (ref($_[0]) eq 'HASH') {
            $params = shift;
        } else {
            $params = { keyword => shift };
        }
    } else {
        $params = { shift };
    }
    
    my @programs;
    my $uri = $self->rss_uri->clone;

    $uri->query_form({
        'stationPlatformId' => $params->{platform} // 0,
        'condition.keyword' => $params->{keyword} // '',
        'stationAreaId' => $params->{area} // 23,
        'condition.genres[0].parentId' => $params->{parent_genre} // -1,
        'condition.genres[0].childId' => $params->{child_genre} // -1,
    });

    my $res = $self->furl->get($uri->as_string);

    if ($res->is_success) {
        my $rss = XML::RSS->new(version => '1.0')->parse($res->content);
        for my $item (@{$rss->{items}}) {
            if ($item->{link} =~ qr{/schedule/(.+)\.action}) {
                my $res = $self->furl->get("http://tv.so-net.ne.jp/iepg.tvpi?id=$1");
                if ($res->is_success) {
                    push @programs, WebService::TVSonet::Program->new(iepg => $res->content);
                }
            }
        }
    } else {
        die "can't fetch: " , $uri->as_string;
    }

    return @programs;
}


1;
__END__

=encoding utf-8

=head1 NAME

WebService::TVSonet - tiny client for http://tv.so-net.ne.jp/

=head1 SYNOPSIS

    use WebService::TVSonet;

    my $client = WebService::TVSonet->new;

    my ($program,) = $client->search('keyword');

    print $program->title;

=head1 DESCRIPTION

WebService::TVSonet is tiny client for 'http://tv.so-net.ne.jp/'.

=head1 METHODS

=item search($keyword)

search TV programs at keyword.
all genre, all platform, tokyo area.

=item search(%params), search($params)

search TV programs at conditions.

B<keyword>

Search keyword. 
It is in agreement with performer information other than the contents of a program, etc. 

B<platform>

0: すべて
1: 地上波
2: BSデジタル
4: スカパー! プレミアムサービス
5: スカパー!

B<area>

10: 北海道（札幌）
11: 北海道（函館）
12: 北海道（旭川）
13: 北海道（帯広）
14: 北海道（釧路）
15: 北海道（北見）
16: 北海道（室蘭）
22: 青森
20: 岩手
17: 宮城
18: 秋田
19: 山形
21: 福島
26: 茨城
28: 栃木
25: 群馬
29: 埼玉
27: 千葉
23: 東京
24: 神奈川
31: 新潟
32: 山梨
30: 長野
37: 富山
34: 石川
36: 福井
39: 岐阜
35: 静岡
33: 愛知
38: 三重
45: 滋賀
41: 京都
40: 大阪
42: 兵庫
44: 奈良
43: 和歌山
49: 鳥取
48: 島根
47: 岡山
46: 広島
50: 山口
53: 徳島
52: 香川
51: 愛媛
54: 高知
55: 福岡
61: 佐賀
57: 長崎
56: 熊本
60: 大分
59: 宮崎
58: 鹿児島
62: 沖縄

B<paren_genre>

100000: ニュース／報道
101000: スポーツ
102000: 情報／ワイドショー
103000: ドラマ
104000: 音楽
105000: バラエティー
106000: 映画
107000: アニメ／特撮
108000: ドキュメンタリー／教養
109000: 劇場／公演
110000: 趣味／教育
111000: 福祉
115000: その他

B<child_genre>

定時・総合: 100100
天気: 100101
特集・ドキュメント: 100102
政治・国会: 100103
経済・市況: 100104
海外・国際: 100105
解説: 100106
討論・会談: 100107
報道特番: 100108
ローカル・地域: 100109
交通: 100110
その他: 100115

スポーツニュース: 101100
野球: 101101
サッカー: 101102
ゴルフ: 101103
その他の球技: 101104
相撲・格闘技: 101105
オリンピック・国際大会: 101106
マラソン・陸上・水泳: 101107
モータースポーツ: 101108
マリン・ウィンタースポーツ: 101109
競馬・公営競技: 101110
その他: 101115

芸能・ワイドショー: 102100
ファッション: 102101
暮らし・住まい: 102102
健康・医療: 102103
ショッピング・通販: 102104
グルメ・料理: 102105
イベント: 102106
番組紹介・お知らせ: 102107
その他: 102115

国内ドラマ: 103100
海外ドラマ: 103101
時代劇: 103102
その他: 103115

国内ロック・ポップス: 104100
海外ロック・ポップス: 104101
クラシック・オペラ: 104102
ジャズ・フュージョン: 104103
歌謡曲・演歌: 104104
ライブ・コンサート: 104105
ランキング・リクエスト: 104106
カラオケ・のど自慢: 104107
民謡・邦楽: 104108
童謡・キッズ: 104109
民族音楽・ワールドミュージック: 104110
その他: 104115

クイズ: 105100
ゲーム: 105101
トークバラエティ: 105102
お笑い・コメディ: 105103
音楽バラエティ: 105104
旅バラエティ: 105105
料理バラエティ: 105106
その他: 105115

洋画: 106100
邦画: 106101
アニメ: 106102
その他: 106115

国内アニメ: 107100
海外アニメ: 107101
特撮: 107102
その他: 107115

社会・時事: 108100
歴史・紀行: 108101
自然・動物・環境: 108102
宇宙・科学・医学: 108103
カルチャー・伝統文化: 108104
文学・文芸: 108105
スポーツ: 108106
ドキュメンタリー全般: 108107
インタビュー・討論: 108108
その他: 108115

現代劇・新劇: 109100
ミュージカル: 109101
ダンス・バレエ: 109102
落語・演芸: 109103
歌舞伎・古典: 109104
その他: 109115

旅・釣り・アウトドア: 110100
園芸・ペット・手芸: 110101
音楽・美術・工芸: 110102
囲碁・将棋: 110103
麻雀・パチンコ: 110104
車・オートバイ: 110105
コンピュータ・ＴＶゲーム: 110106
会話・語学: 110107
幼児・小学生: 110108
中学生・高校生: 110109
大学生・受験: 110110
生涯教育・資格: 110111
教育問題: 110112
その他: 110115

高齢者: 111100
障害者: 111101
社会福祉: 111102
ボランティア: 111103
手話: 111104
文字（字幕）: 111105
音声解説: 111106
その他: 111115

その他: 115115


=head1 SEE ALSO

L<WebService::TVSonet::Program>

=head1 LICENSE

Copyright (C) Kan Fushihara.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Kan Fushihara E<lt>kan.fushihara@gmail.comE<gt>

=cut

