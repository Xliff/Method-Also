use v6.c;

module Method::Also:ver<0.0.3>:auth<cpan:ELIZABETH> {
    our %aliases;
    my %aliases-composed;

    # sub getTheList(\o) {
    #   for %aliases{o.^name}[] {
    #     next unless $_;
    #     my $mn = .value ?? "Method { .value.name }" !! 'UNDEFINED METHOD!';
    #     say "{ .key.fmt("%-20s") } --> $mn";
    #   }
    # }

    role AliasableClassHOW {
        method compose (Mu \o, :$compiler_services) is hidden-from-backtrace {
          my @r := self.roles_to_compose(o);
          # Copy the roles because they are consumed by the superclass method.
          my $ri = 0;

          # How do I deal with a BOOTArray?!
          # while $ri < +@r {
          #   # Why won't left side bind? Also... why is it immutable?
          #   # Are its ELEMENTS immutable?
          #   @!roles-to-compose[$ri] := @r[$ri++];
          # }

          for %aliases{o.^name}[] {
            next unless $_;
            #say "Class: Adding alias {.key} to {o.^name} as {.value.name}...";
            o.^add_method(.key, .value) if $_;
          }
          for @r -> \r {
            say "R: { r.^name }";
            unless %aliases-composed{r.^name} {
              for %aliases{r.^name}[] -> $p {
                # cw: This should never happen, but somehow it is...
                next unless $p;
                next unless $p.value.is_dispatcher;

                say "Role: Adding alias {$p.key} to {r.^name} as {$p.value.name}...";

                o.^add_method(
                  $p.key,
                  -> |c { o."{ $p.value.name }"( |c.list.skip(1), |c.hash ) }
                );
              }
            }
            %aliases-composed{r.^name} = True;
          }
          nextsame;
        }

        # # This method supposedly doesn't exist in the superclass:
        # #   https://colabti.org/irclogger/irclogger_log/raku-dev?date=2019-12-27#l111
        # # so how was it to be invoked?
        # method incorporate_multi_candidates ($obj) {
        #   # .multi_methods_to_incorporate DOES exist, so is this supposed to
        #   # be a callnext?
        #   my @multis := self.multi_methods_to_incorporate;
        #   my $*TYPE-ENV;
        #   my \r := callsame;
        #   for @!roles-to-compose -> \r {
        #     say "R: { r.^name }";
        #     unless %aliases-composed{r.^name} {
        #       for %aliases{r.^name}[] -> $p {
        #         # cw: This should never happen, but somehow it is...
        #         next unless $p;
        #         next unless $p.value.is_dispatcher;
        #
        #         say "Role: Adding alias {$p.key} to {r.^name} as {$p.value.name}...";
        #
        #         $obj.^add_method($p.key, $p.value);
        #         for @multis {
        #           $obj.^add_multi_method(
        #             $p.key,
        #             .code.instantiate_generic($*TYPE-ENV)
        #           );
        #         }
        #       }
        #     }
        #     %aliases-composed{r.^name} = True;
        #   }
        # }

        # method specialize_with(Mu $, Mu \old_type_env, Mu \type_env, |) {
        #     $*TYPE-ENV := old_type_env.^name eq 'BOOTContext'
        #       ?? old_type_env
        #       !! type_env;
        # }
        #
        # method list-aliases (Mu \o) { getTheList(o) }

    }

    role AliasableRoleHOW {
      # Dummy reference code, now.
        # method incorporate_multi_candidates ($obj) {
        #   my @multis := self.multi_methods_to_incorporate;
        #   my $*TYPE-ENV, $*ROLE;
        #   my \r := callsame;
        #   unless %aliases-composed{r.^name} {
        #     for %aliases{r.^name}[] -> $p {
        #       # cw: This should never happen, but somehow it is...
        #       next unless $p;
        #       next unless $p.value.is_dispatcher;
        #
        #       say "Role: Adding alias {$p.key} to {r.^name} as {$p.value.name}...";
        #
        #       obj.^add_method($p.key, $p.value);
        #       for r.^multi_methods_to_incorporate {
        #           obj.^add_multi_method(
        #               $p.key,
        #               .code.instantiate_generic($*TYPE-ENV)
        #           );
        #       }
        #   }
        #   %aliases-composed{r.^name} = True;
        # }
        #
        # method specialize(Mu \r, Mu:U \obj, *@pos_args, *%named_args)
        #     is hidden-from-backtrace
        # {
        #   $*ROLE := r;
        #   callsame;
        # }
        #
        # method specialize_with (Mu \obj, Mu \type_env, @pos_args) {
        #   $*TYPE-ENV := type_env;
        #   nextsame;
        # }
        #
        # method list-aliases (Mu \o) { getTheList(o) }
    }

    multi sub trait_mod:<is>(Method:D \meth, :$also!) is export {
      my \h := $*PACKAGE.HOW;
      my \n := $*PACKAGE.^name;

      # my @elegible-roles = (
      #   Metamodel::ParametricRoleHOW,
      #   Metamodel::ParametricRoleGroupHOW
      # );

      if h ~~ Metamodel::ClassHOW {
        h does AliasableClassHOW unless h ~~ AliasableClassHOW;
        #h does AliasableRoleHOW  unless h ~~ AliasableRoleHOW;
      }

      # if h ~~ @elegible-roles.any {
      #   say "»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»» Punning ROLE to { h.^name }!";
      #   #h does AliasableRoleHOW  unless h ~~ AliasableRoleHOW;
      # }

      if $also {
        if $also ~~ List {
            for @$also {
              say "Adding alias in { n } for { .Str }...";
              %aliases{n}.push: Pair.new(.Str, meth)
            };
        }
        else {
            say "Adding alias in { n } for { $also.Str }...";
            %aliases{n}.push: Pair.new($also.Str, meth);
        }
      }
    }
}

=begin pod

=head1 NAME

Method::Also - add "is also" trait to Methods

=head1 SYNOPSIS

  use Method::Also;

  class Foo {
      has $.foo;
      method foo() is also<bar bazzy> { $!foo }
  }

  Foo.new(foo => 42).bar;       # 42
  Foo.new(foo => 42).bazzy;     # 42

  # separate multi methods can have different aliases
  class Bar {
      multi method foo()     is also<bar>   { 42 }
      multi method foo($foo) is also<bazzy> { $foo }
  }

  Bar.foo;        # 42
  Bar.foo(666);   # 666
  Bar.bar;        # 42
  Bar.bazzy(768); # 768

=head1 DESCRIPTION

This module adds a C<is also> trait to C<Method>s, allowing you to specify
other names for the same method.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Method-Also .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018-2019 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
