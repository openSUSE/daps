#!perl
use strict;
use warnings;
use Test::More tests => 4;
use SUSEDOC;
my $o = SUSEDOC->new(foo => 'bar');
ok(defined($o), "basic new");
isa_ok($o, 'SUSEDOC');
$o->env(FOO=>'BAR');
$o->export_env();
ok($ENV{FOO} eq 'BAR', 'export_env found FOO=BAR');
ok(!defined $ENV{foo}, "params to 'new' are not in env");
