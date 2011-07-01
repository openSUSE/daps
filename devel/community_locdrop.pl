#! /usr/bin/perl -w
#
# community_locdrop.pl -- create nightly locdrops for our translators 
#
# Algorithm:
# - checkout the master tree, if needed.
#  - collect all project_files, including images.
# - run dmstat to get a full dump as one overview page in xml.
# - checkout the locdrop tree, if needed.
# - remove all files from the locdrop tree.
# - copy over all project_files using
#   do_regexp_filter($ifile, $ofile, { strip_comments => 0, keep_role => 'trans' });
# - run svn add - in the tree root, to catch any new files.
# - run svn status -v recursively, to learn about missing files.
# - call svn delete for all missing files.
# - call svn ci, to push the new tree into the server.
#
# Requires: susedoc from home:thomas-schraitle
#           perl-SUSEDOC from devel:tools:documentation
# if using the stylesheet engine: perl-XML-LibXML perl-XML-LibXSLT
#
# toms:
# Stylesheet is now available under
# https://svn.berlios.de/svnroot/repos/opensuse-
# docmaker/trunk/xslt/misc/preserve-remark.trans.xsl
# (Maybe we need some more parameters, we will see.)
# It preserves/copies everything, but handles remarks differently: Only those 
# with role="trans" survives the transformation, others are discarded.
# Depends on copy.xsl in the same directory.
#
# 2010-05-30, jw, V0.05 -- rewritten half done code to using SUSEDOC perl library, 
#                          instead of make and dm calls from susedoc package.
#                          Now we have much better chances to survive invalid XML.
#                          Moving from suse.de to berlios.de repo.

use FindBin;
use lib "$FindBin::Bin/../lib/perl/SUSEDOC"; 
use SUSEDOC;

# use XML::LibXSLT;
# use XML::LibXML;
use Getopt::Long;
use File::Copy ();
use File::Find ();
use Data::Dumper;
my $version = '0.5';

my $cfg =
{
  # disable use_regexp to use the XSLT engine...
  filter_spec => { use_regexp => 1, strip_comments => 1, keep_role => 'trans' },
  dmstat => 
    { 
      fields => [qw(name maintainer trans status priority deadline)],
    },
  master => 
    {
      co_dir   => "$ENV{HOME}/src/svn-co/doc/trunk/books/en",
      svn_url  => "https://svn.suse.de/svn/doc/trunk/books/en",
      env_file => "ENV-opensuse-all",
    },
  locdrop =>
    {
      co_dir =>  "$ENV{HOME}/src/svn-co/opensuse-doc/trunk/books/distribution/en/locdrop",
      svn_url => "https://testy-jw\@svn.berlios.de/svnroot/repos/opensuse-doc/trunk/books/distribution/en/locdrop",
      user =>    "testy-jw",
      pass =>    "\x74\x65\x73\x74\x79x2d\x6a\x77",
    }
};

my $verbose = 1;
my $help = 0;
my $do_write = 0;

if (!GetOptions (
            "strip-comments!"	=> \$cfg->{filter_spec}{strip_comments},
	    "use-regexp!"       => \$cfg->{filter_spec}{use_regexp},
	    "verbose+"		=> \$verbose, 
	    "write"		=> \$do_write,
	    "quiet"		=> sub { $verbose=0 },
	    "help|?"		=> \$help) or $help)
  {
    printf STDERR qq{community-locdrop version $version

Usage:
$0 [options]

Valid options are:
 -v             be more verbose.
 -q             be quiet.
 -strip-comments
 -no-strip-comments
 		Preserve or strip all comments. 
		Default: strip=$cfg->{filter_spec}{strip_comments}
 --use-regexp
 --no-use-regexp
 		Process with XSLT or perl regexp.
		Default regexp=$cfg->{filter_spec}{use_regexp}
 -w		
 		Actually enable writing to locdrop.
		Default: Pull and check only.

Please see also the \$cfg section of $0, here the master and 
locdrop locations are configured.

Local checkouts of master and locdrop are held in
$cfg->{master}{co_dir}
$cfg->{locdrop}{co_dir}
};
  exit(0);
  }


prep_chdir_svn_co($cfg->{master});

my $ctx = new SUSEDOC( env => "$cfg->{master}{co_dir}/$cfg->{master}{env_file}" );
my $list = $ctx->project_files();
die Dumper $list;
my $props;
for my $f (keys %$list)
  {
    ## yes, all including the images...
    if ($list->{$f}{type} eq 'img')
      {
        ## when do we convert the images?
	#
	## fileref="sled10_ad_schema.svg"
	## fileref="sled10_ad_schema.png"
	#
	for my $i ($ctx->find_image_files($f))
	  {
            $props->{$i} = $ctx->file_prop_info($i);
	  }
      }
    else
      {
        $props->{$f} = $ctx->file_prop_info($f);
      }
  }
die Dumper $props, $ctx->{env};

my $tar_dir = mk_community_locdrop($cfg);
# my $tar_dir = '/home/testy/src/svn-co/doc/trunk/books/en/locdrop-opensuse-all';
  
prep_chdir_svn_co($cfg->{locdrop});
opendir DIR, $tar_dir;
my @f = grep { -f } map { "$tar_dir/$_" } readdir DIR;
closedir DIR;
for my $f (@f)
  {
    if ($f =~ m{(\.tar\.gz|\.tar\.bz2|\.tgz|\.tar)$})
      {
        print STDERR "tar xf $f\n";
        system "tar xf $f";
      }
    else
      {
        print STDERR "cp $f\n";
	File::Copy::copy($f, '.') or die "copy($f) failed: $!";
      }
  }
#
# now all copied/extracted files have ctime later than script start, all
# others have ctime earlier than script start.
# we use this property to find all those files that have been copied in.
File::Find::find({ wanted => sub 
{ 
  return if -d;

  # do not enter into .svn
  return if $File::Find::dir =~ m{/\.svn(/|$)};

  # a file that has not been refreshed needs to go.
  system "echo svn delete '$_'" if 0.0 < -C $_;

  return unless /\.xml$/i;

  if (!$cfg->{filter_spec} or !$cfg->{filter_spec}{use_regexp})
    {
die "filter_remark_xsl is deprecated\n";
      my $filtered_xml = filter_remark_xsl($_);
      unlink $_;	# so that we can write, even if permissions were odd.
      open O, ">", $_ or die "cannot write $_: $!";
      print O $filtered_xml;
      close O or die "could not write $_: $!";
    }
  else
    {
      ## inplace comment filtering: open, unlink, open creat.
      ## (this way we read and write the same filename, without conflicts.)
      open IN, "<", $_ or die "cannot read $_: $!";
      unlink $_;
      do_regexp_filter(\*IN, $_, $cfg->{filter_spec});
      close IN;
    }
} }, '.');

# add all files (recursivly) is harmless if done twice, but safe.

my $msg = "$0 v0.3 [".scalar localtime;
local $Data::Dumper::Terse=1;
local $Data::Dumper::Indent=0;
$msg .= "] $cfg->{master}{env_file} " . Dumper $cfg->{filter_spec};
print  "svn add .\n";
system "svn add ." if $do_write;
print  "svn commit -m '$msg'\n";
system "svn commit -m '$msg'" if $do_write;

exit 0;
##############################################################################

sub prep_chdir_svn_co
{
  my ($svn) = @_;

  print "prep $svn->{svn_url}\n as $svn->{co_dir}\n";
  unless (-d $svn->{co_dir})
    {
      (my $parent_dir = $svn->{co_dir}) =~ s{/[^/]+/*$}{};
      chdir $parent_dir or die "chdir $parent_dir failed: $!\n";
      print  "svn co $svn->{svn_url}\n" if $verbose;
      system "svn co $svn->{svn_url}";
      chdir $svn->{co_dir} or die "cannot chdir $svn->{co_dir}: $!\n";
    }
  else
    {
      chdir $svn->{co_dir} or die "cannot chdir $svn->{co_dir}: $!\n";
      print  "svn up\n" if $verbose;
      system "svn up";
    }
}

sub mk_community_locdrop
{
  my ($cfg) = @_;

  die "ENV setup not done. E.g. DTDROOT not set\n" unless $ENV{DTDROOT};
  chdir $cfg->{master}{co_dir} or die "cannot chdir $cfg->{master}{co_dir}: $!\n";

  my $line_no = 0;
  my @last = ();	# a little ring-buffer
  my @fields =  @{$cfg->{dmstat}{fields}};
  my $dmstat = sprintf $cfg->{dmstat}{cmd_fmt}, join(' ', map { "\%{$_}" } @fields);
  my $dmstat_file = $cfg->{master}{env_file}; $dmstat_file =~ s{^ENV-}{DMSTAT-};
  print "$dmstat\n" if $verbose;
  open IN, "-|", "$dmstat 2>&1" or die "cannot run '$dmstat': $!\n";
  open OUT, ">", "$cfg->{master}{co_dir}/$dmstat_file"   or die "cannot write '$dmstat_file': $!\n";
  print OUT "<dmstat version=\"$version\">\n";
  while (defined (my $line = <IN>))
    {
      chomp $line;
      next if $line =~ m{^\%\{};
      my @line = split /\s+/, $line;
      next if scalar(@line) != scalar(@fields);
      print OUT "  <file";
      for my $i (0..$#fields)
	{
	  print OUT " $fields[$i]=\"$line[$i]\"";
	}
      print OUT "/>\n";
      $line_no++;
    }
  close IN;
  print OUT "</dmstat>\n";
  close OUT or die "write $dmstat_file failed: $!\n";
  print "$dmstat_file written\n" if $verbose;
  print STDERR "$line_no packages from '$dmstat'\n";

  for my $i (1..100)
    {
      my %bad_file;
      $line_no = 0;
      @last = ();
      print "make validate\n" if $verbose;
      open IN, "-|", "make validate 2>&1" or die "cannot run 'make validate': $!\n";
      while (defined (my $line = <IN>))
	{
	  chomp $line;
	  if ($line =~ m{(does not validate|parser error|Entity)})
	    {
	      print "] $line\n";
	      $bad_file{$1}++ if $line =~ m{(/[^/]+\.xml)\b} and $line !~ m{Entity .* not defined};
	    }
	  unshift @last, $line;
	  pop @last if $#last > 3;
	  printf STDERR " v %d\r", ++$line_no;
	}
      close IN;

      if (scalar keys %bad_file)
        {
	  system "rm -rf profiled tmp";
	  for my $file (keys %bad_file)
	    {
	      print "svn up -r PREV 'xml/$file'\n" if $verbose;
	      system "svn up -r PREV 'xml/$file'";
	    }
	  %bad_file = ();
	  next;
	}
      last;
    }

  if ($last[0] !~ m{\*\*\*Validating done\s})
    {
      # left over broken profiled dir confuses make validate.
      # zap it, so that we have better chances next time.
      system "rm -rf profiled tmp";	
      die sprintf "| %s\nmake validate failed.\n", join "\n| ", reverse @last;
    }

  $line_no = 0;
  @last = ();
  $ENV{FOP} = '/bin/touch';
  $ENV{FOPOPTIONS} = '';
  open IN, "-|", "make locdrop 2>&1" or die "cannot run 'make locdrop': $!\n";
  while (defined (my $line = <IN>))
    {
      chomp $line;
      print "$line\n" if $line =~ m{(parser error|Entity)};
      unshift @last, $line;
      pop @last if $#last > 3;
      printf STDERR " l %d\r", ++$line_no;
    }

  $tar_dir = $cfg->{master}{env_file};
  $tar_dir =~ s{^ENV-}{locdrop-};
  $tar_dir = $cfg->{master}{co_dir} . "/" . $tar_dir;
  rename    "$cfg->{master}{co_dir}/$dmstat_file", "$tar_dir/$dmstat_file";
  return ($tar_dir, \@last);
}

##
sub do_regexp_filter
{
  my ($ifd, $ofd, $cfg) = @_;
  open $ifd, "<", $ifd or die "failed to open <$ifd\n" unless ref $ifd;
  open $ofd, ">", $ofd or die "failed to open >$ofd\n" unless ref $ofd;
  local $/;

  my %keep = map { $_ => 1 } split /[,\s]+/, $cfg->{keep_role}||'';
  my $xml = <$ifd>;
  $xml =~ s{<!--.*?-->}{}gs if $cfg->{strip_comments};
  $xml =~ s{(<remark(\s+role="?(\w+)"?)?.*?</remark>)}{$keep{$3||''}?$1:''}essig;
  print $ofd $xml; 
}

sub filter_remark_xsl
{
  my ($file) = @_;
  open $ifd, "<", $file or die "failed to open <$file\n";
  local $/;
  my $xml = <$ifd>;
  close $ifd;

  my %ents;
  while ($xml =~ m{&(\w+);}g) { $ents{$1}++; }
  my $entity_list = '';
  for my $e (sort keys %ents)
    {
      $entity_list .= qq{<!ENTITY $e "<?entity_pi '&#x26;$e;'?>">\n};
    }
        
  ## options: see XML::LibXML::Parser
  my $source = XML::LibXML->load_xml(string => $xml, expand_entities=>1,
  ext_ent_handler => sub { return $entity_list; }, validate=>0, suppress_errors=>1, suppress_warnings=>1);
  my $style_doc = XML::LibXML->load_xml(string=>q{<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

 <!--
   This xsl:template copies elements, attributes and other nodes.
   If you need to specialize you have to overwrite it
   with a special template
 -->
 <xsl:template match="node() | @*">
   <xsl:copy>
     <xsl:apply-templates select="@* | node()"/>
   </xsl:copy>
 </xsl:template>

 <!--
   Don't copy remark and XML comments, but copy <remark role='trans'>
 -->
 <xsl:template match="comment()"/>
 <xsl:template match="remark"/>
 <xsl:template match="remark[@role='trans']">
  <xsl:copy><xsl:apply-templates select="@* | node()"/></xsl:copy>
 </xsl:template>
 <xsl:output encoding="ascii"/>
</xsl:stylesheet>
}, no_cdata=>1);
	      
  my $xslt = XML::LibXSLT->new();
  my $stylesheet = $xslt->parse_stylesheet($style_doc);
  my $results = $stylesheet->transform($source);

  my $bytes = $stylesheet->output_as_bytes($results);
  $bytes =~ s{(<\?entity_pi '&(\w+);'\?>)}{ warn "Warning: unexpected $1 \n" unless $ents{$2}; "&$2;"}ge;
  return $bytes;
}


