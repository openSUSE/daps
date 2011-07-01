#! /usr/bin/perl -w
#
# project_files.pl -- find all files that contribute to some ENV
#
# (C) 2010 jw@suse.de, Novell Inc.
# Distribute under GPLv2 or GPLv3
#
# 2010-02-25, jw, v0.1 -- inital draught
# 2010-05-25, jw, v0.2 -- renamed from dm_files to project_files
#                         added support for svn based retry in case of xml parse errors.
# 2010-05-30, jw, v0.3 -- made code reusable, moved into SUSEDOC.pm

use FindBin;
use lib "$FindBin::Bin/../lib/perl/SUSEDOC"; 
use lib "/usr/share/libsusedoc/lib/perl/SUSEDOC";

use SUSEDOC;
use XML::Parser;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

my $version = $SUSEDOC::VERSION;
my $verbose = 1;

my ($help, $prof, $profos, $all_files, $img_only, $long_list);

my %opt = ( prev_cmd => undef, restore_cmd => undef, retry_limit => 10 );

## BUG ALERT: -P without parameter, gives this misleading error message:
##  Option p requires an argument
#
GetOptions(
	"all" 	   => \$all_files,
	"verbose+" => \$verbose,
	"quiet"    => sub { $verbose = 0; },
	"images"   => \$img_only,
	"long"     => \$long_list,
	"profos=s" => \$profos,
	"help|?"   => \$help,
	"previous-file-cmd|P=s"  => \$opt{prev_cmd},
	"cleanup-file-cmd|C=s"   => \$opt{restore_cmd},
	"retry-limit=i"	       => \$opt{retry_limit},
);

pod2usage(-verbose => 1, -msg => qq{
project_files V$version Usage: 

$0 [options] startfile.xml
$0 [options] ENV-startfile
env MAIN=MAIN.file.xml $0 [options]

Valid options are:
 -v	Be more verbose. Default: $verbose.
 -q     Be quiet, not verbose.

 -a --all
 	Print all files, xml and images. Default: xml
 -i --images
 	Print images only. Default: xml files.

 -p --profos
 	Profile for one operating system.
	Default from ENV{PROFOS}, otherwise: any.
	Use '-p --' to ignore profiling from ENV.
	Use '-p -osuse' to exclude openSUSE specifc parts.

 -l --long
 	List 3 column layout: filename, profiling, parent_file[node...]
	A list of node numbers, specifies the xml-node where the file was included.
	Default: filenames only.

 -P --previous-file-cmd "svn revert '%s'; svn up -r PREV '%s'"
 	Run the specified command if XML::Parse fails. Useful to e.g. fetch an earlier version
	from svn, hoping to avoid a newly introduced bug.

 -C --cleanup-file-cmd  "svn up -r HEAD '%s'"
 	Run the specifed command, after all error recovery attempts. This should restore the
	file to the state it was before.

 -r --retry-limit NNN
 	Run previous-file-cmd at most NNN times for a file. Default $opt{retry_limit}

 -h -? --help
 	Show this online help.

project_files does a quick file tree walk through docbook xml files.
It follows <xi:include href=...> and finds <imagedata fileref=...>
and optionally honors profiling information while doing so.

}) if $help;

my $start = shift;
my $ctx = new SUSEDOC(env => $start, profos => $profos);

die "please give an ENV or xml file to start with (or source an ENV file).\n" 
  unless $ctx->env->{MAIN};

my $list = $ctx->project_files( %opt );

for my $f (sort keys %$list)
  {
    my $print = $all_files || $list->{$f}{type} eq 'xml';
    $print = $list->{$f}{type} eq 'img' if $img_only;
    next unless $print;

    if ($long_list)
      {
        my $os = $list->{$f}{os};
	my $prof = '-';
	if (keys %$os and !$os->{'*'})
	  {
	    $prof = 'os="'.join('","', sort keys %$os).'"';
	  }
        printf "%-50s %-10s %s\n", $f, $prof, $list->{$f}{via};
      }
    else
      {
        print "$f\n" if $print;
      }
  }

exit 0;
#######################################################
