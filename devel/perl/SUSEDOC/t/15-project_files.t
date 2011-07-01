#!perl
#
# also requires XML::Parser
#
use strict;
use warnings;
use Test::More tests => 6;

use FindBin;
use lib "$FindBin::Bin/..";
use SUSEDOC;

delete $ENV{XMLDIR};
delete $ENV{MAIN};	# don't get fooled by unix environment.

my $o = SUSEDOC->new(env => 't/xml/ENV-SLE-smt');
ok(defined($o->{env}), "have ENV");
ok($o->{env}{MAIN} eq 't/xml/MAIN.SMT.xml', "found MAIN");

my $unreadable = 0;
my $l = $o->project_files(parse_error => sub { $unreadable++; 1; });
ok(ref $l eq 'HASH', 'list files as hashes');
SKIP: {
  ## We only skip, iff the parser fails to load.
  skip "XML::Parser not loaded", 2 unless $o->{xml};
  ok($unreadable == 13, "skipped $unreadable unreadable files");
  ok($l->{'smt_scripts.xml'}{via} eq 'smt_tools.xml[1;chapter][12;xi:include]', 
     $l->{'smt_scripts.xml'}{via} . ": indirect href seen");
}
$l = $o->project_files(parse_error => sub { 1 }, list => 'files');
ok(ref $l eq 'ARRAY', 'list files as array');

