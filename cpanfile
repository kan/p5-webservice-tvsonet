requires 'perl', '5.008001';
requires 'Furl';
requires 'URI';
requires 'Time::Piece';
requires 'Mouse';
requires 'XML::RSS';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

