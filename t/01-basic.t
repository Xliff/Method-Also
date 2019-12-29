use v6.c;
use Test;

use Method::Also;

plan 13;

class A {
    has $.foo;
    method foo() is also<bar bazzy> is rw { $!foo }
}

my $a = A.new(foo => 42);
is $a.foo,   42, 'the original foo';
is $a.bar,   42, 'the first alias bar';
is $a.bazzy, 42, 'the second alias bazzy';

role Ber {
    proto method bar_ber (|)
        is also<bar-ber>
    { * }

    multi method bar_ber (Str $a) {
        'Str';
    }

    multi method bar_ber (Int $a) {
        'Int';
    }

    multi method bar_ber (:$hazzy is required) {
        'Hazzy';
    }
}

class Bar does Ber {
    multi method foo()     is also<bar>   { 42 }
    multi method foo($foo) is also<bazzy> { $foo }
}

is Bar.foo,                  42, 'is foo() ok';
is Bar.foo(666),            666, 'is foo(666) ok';
is Bar.bar,                  42, 'is bar() ok';
is Bar.bazzy(768),          768, 'is bazzy(768) ok';
is Bar.bar_ber('a'),      'Str', "is Bar.bar_ber('a') ok";
is Bar.bar_ber(42),       'Int', "is Bar.bar_ber(42) ok";
is Bar.bar_ber(:hazzy), 'Hazzy', "is Bar.bar_ber(:hazzy) ok";
is Bar.bar-ber('a'),      'Str', "is Bar.bar-ber('a') ok";
is Bar.bar-ber(42),       'Int', "is Bar.bar-ber(42) ok";
pass 'This is not a test!';
is Bar.bar-ber(:hazzy), 'Hazzy', "is Bar.bar-ber(:hazzy) ok";

# vim: ft=perl6 expandtab sw=4
