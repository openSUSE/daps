#!perl -T
use strict;
use warnings;
use Test::More tests => 3;
use SUSEDOC;
my $o = SUSEDOC->new(profos => 'osuse,osuse;!sles;-sled,-ha,smt');
ok(defined($o->{prof}), "have prof");
my $p = $o->{prof};
ok(scalar(keys %{$p->{pos}}) == 2 && 
   scalar(keys %{$p->{neg}}) == 3, "have 2+3 keys");
ok(defined($p->{pos}{osuse}) && 
   defined($p->{pos}{smt}) && 
   defined($p->{neg}{sles}) && 
   defined($p->{neg}{ha}) && 
   defined($p->{neg}{sled}), "seen all pos/neg keys");
