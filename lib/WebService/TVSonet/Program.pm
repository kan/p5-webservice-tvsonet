package WebService::TVSonet::Program;
use Mouse;

use Time::Piece;
use Encode;

has title => ( is => 'rw', isa => 'Str' );

has station => ( is => 'rw', isa => 'Str' );

has date => ( is => 'rw', isa => 'Time::Piece' );

has start => ( is => 'rw', isa => 'Time::Piece' );

has end => ( is => 'rw', isa => 'Time::Piece' );

has genre => ( is => 'rw', isa => 'Int' );

has subgenre => ( is => 'rw', isa => 'Int' );

has description => ( is => 'rw', isa => 'Str' );


around BUILDARGS => sub {
    my ($orig, $class, %params) = @_;
    my $iepg = delete $params{iepg};
    $iepg = decode('cp932', $iepg);

    my $body = '';
    my $body_fg = 0;
    my %date;
    for (split /\r?\n/, $iepg) {
        if ($body_fg) {
            $body .= $_;
        } elsif (/^$/) {
            $body_fg = 1;
        } elsif (/^(.+?): (.+)$/) {
            my ($key, $val) = ($1, $2);
            for my $k (qw/station genre subgenre start end/) {
                $params{$key} //= $val if $key eq $k;
            }
            for my $k (qw/year month date/) {
                $date{$key} = $val if $key eq $k;
            }
            $params{title} //= $val if $key eq 'program-title';
        }
    }

    $params{date}  = Time::Piece->strptime(sprintf('%s-%s-%s', @date{qw(year month date)}),
                                           '%Y-%m-%d');
    $params{start} = Time::Piece->strptime(sprintf('%s-%s-%s %s', @date{qw(year month date)}, delete $params{start}),
                                           '%Y-%m-%d %H:%M');
    $params{end}   = Time::Piece->strptime(sprintf('%s-%s-%s %s', @date{qw(year month date)}, delete $params{end}),
                                           '%Y-%m-%d %H:%M');

    $class->$orig(description => $body, %params);
};

no Mouse;
__PACKAGE__->meta->make_immutable;

1;

