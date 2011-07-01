#! /usr/bin/perl -w
# 
# dmstat.pl -- a remake of dmstat, using the SUSEDOC library
#
# 2010-05-30, V0.1, jw -- initial draught.
# 2010-05-30, V0.2, jw -- moved xml generation to SUSEDOC::dmstat_fmt_xml()
# 2010-07-20, V0.3, jw -- allow multiple file with -f, nicer column formatting.

use FindBin;
use lib "$FindBin::Bin/../lib/perl/SUSEDOC"; 
use SUSEDOC;

use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

my $version = '0.3';
my $verbose = 1;
my $xmlout = 0;
my ($help, @singlefile, $all_files, $listprops);
my $p = [qw{doc:status doc:maintainer doc:trans doc:prelim svn:info:last_changed_date svn:info:last_changed_author svn:info:last_changed_rev svn:info:checksum}];

GetOptions(
	"all" 	       => sub { $p = undef; },
	"verbose+"     => \$verbose,
	"quiet"        => sub { $verbose = 0; },
	"properties=s" => sub { $p = ($_[1] =~ m{,}) ? [split /,/, $_[1]] : $_[1]; },
	"file=s{,}"      => \@singlefile,
	"includegraphics" => \$all_files,
	"listprops"    => \$listprops,
	"xml"          => \$xmlout,
	"help|?"       => \$help,
) or $help=1;

pod2usage(-verbose => 1, -msg => qq{
dmstat.pl V$version Usage: 

$0 [options] [ENV-file]
env MAIN=MAIN.file.xml $0 [options]
. ./ENV-file; $0 [options]

Valid options are:

 -p --properties LIST|REGEXP
      Specify printed properties as a comma seperated LIST, 
      or (if no comma occurs) as a REGEXP.
 -a --all
      Include all properies.  Default properties:
      @$p

 -f --file FILE ...
      Print stats only for the specified FILE(s).
      Default: all project-files belonging to the 
      sourced or specified ENV-file.

 -i --includegraphics
      Also print stats for used graphics files.
      This option has no effect with -f .
      Default: only docbook files are considered project-files.
      
 -l --listprops
      Print a list of matching property names only.

 -x --xml
      Format output as XML.

 -v   Be more verbose. Default: $verbose.
 -q   Be quiet, not verbose.
 -h -? --help
 	Show this online help.

}) if $help;

my $ctx = new SUSEDOC(env => shift);
my %stat;
if (@singlefile)
  {
    #$singlefile ||= '/home/testy/src/svn-co/doc/trunk/books/en/ENV-opensuse-all';
    for my $file (@singlefile)
      {
        $stat{$file} = $ctx->file_prop_info($file, $p);
      }
  }
else
  {
    die "not impl; this needs code from project_files\nTry\n$0 -f file.xml";
  }

if ($xmlout)
  {
    print $ctx->dmstat_fmt_xml(\%stat, $listprops);
  }
else
  {
    $p = SUSEDOC::_collect_subkeys(\%stat);
    if ($listprops)
      {
	map { print "$_\n" } (@$p);
	exit 0;
      }

    my $header = qq{filename         }.join(' ', map { shortname($_); } (@$p));
    print "$header\n" . ('-' x length($header)) . "\n";

    my $filename_len = 14;
    my %p;
    my %w;
    for my $file (sort keys %stat)
      {
        $filename_len = length $file if length $file > $filename_len;
        my $s = $stat{$file};
	for my $k (@$p)
	  {
	    my $v = $s->{$k} || '-';
	    $v = "'$v'" if $v =~ s{\s}{ }g;
            $w{$k} ||= 2;
	    $w{$k} = length $v if length $v > $w{$k};
	    $p{$file}{$k} = $v;
	  }
      }

    for my $file (sort keys %stat)
      {
	printf "%-*s", $filename_len, $file;
	for my $k (@$p)
	  {
	    printf " %-*s", $w{$k}, $p{$file}{$k};
	  }
	print "\n";
      }
  }

exit 0;
#################################
sub shortname
{
  my ($name) = @_;
  $name =~ s{^doc:}{};
  $name =~ s{^.*_changed_}{c_};
  $name =~ s{^svn:info:}{si_};
  $name =~ s{^svn:}{s_};
  return $name;
}
