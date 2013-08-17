package WebService::TVSonet;
use Mouse;
use utf8;

use URI;
use Furl;
use XML::RSS;

use WebService::TVSonet::Program;

our $VERSION = "0.01";

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
    my ($self, $keyword) = @_;
    
    my @programs;
    my $uri = $self->rss_uri->clone;

    $uri->query_form({
        'stationPlatformId' => 0,
        'condition.keyword' => $keyword,
        'stationAreaId' => 23,
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

WebService::TVSonet - It's new $module

=head1 SYNOPSIS

    use WebService::TVSonet;

=head1 DESCRIPTION

WebService::TVSonet is ...

=head1 LICENSE

Copyright (C) Kan Fushihara.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Kan Fushihara E<lt>kan.fushihara@gmail.comE<gt>

=cut

