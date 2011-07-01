#! /usr/bin/perl -w
#
# Copyright (C) 2011 jw@suse.de, openSUSE.org
#
# mkdist.pl -- building a dist- tar ball.
# Optionally checks the output of $usage_cmd : 
# It must contain the version number 
# retrieved from $spec file.
#
# 2011-04-12, jw -- taken from licensedigger

#my %include = ( '.' => '*' );
my %include = (
  '.'	      => [qw{Makefile mkdist.pl}],
  '../../bin' => [qw{dmstat.pl project_files.pl project_files.py}],
  '../../lib' => [qw{perl python}]
);

my @exclude = qw(
  .svn
  \*.orig
  dist
);

use File::Path;

my $spec = shift;		# mandatory
my $usage_cmd = shift;		# optional

die "usage: $0 specfile.spec\n" unless $spec;

open IN, "<$spec" or die "cannot derive version from spec-file: '$spec': $!\n";
my $version = undef;
my $name = undef;

my $verbose = 1;

while (defined( my $line = <IN>))
  {
    chomp $line;
    if ($line =~ m{^Version:\s+(\S+)\s*$})
      {
        $version = $1;
	last if $name and $version;
      }
    if ($line =~ m{^Name:\s+(\S+)\s*$})
      {
        $name = $1;
	last if $name and $version;
      }
  }
close IN;

if ($usage_cmd)
  {
    my $vers_found = 0;
    open IN, "$usage_cmd 2>&1|" or die "cannot run '$usage_cmd': $!\n";
    my $count = 0;
    my $text = '';
    while (defined( my $line = <IN>))
      {
        chomp $line;
	if ($line =~ m{\sV$version\s})
	  {
	    $vers_found++;
	    last
	  }
	if ($count++ > 5)
	  {
	    last;
	  }
	$text .= "$line\n";
      }
    close IN;
    die "Version number '$version' (from $spec) not found in output of '$usage_cmd', please check.\n\n" . $text 
      unless $vers_found;
  }

print "$name-$version\n" if $verbose;

File::Path::remove_tree("dist/$name-$version");
unlink "dist/$name-$version.tar.bz2";
mkdir "dist";
mkdir "dist/$name-$version";
chdir "dist/$name-$version" or die "cannot chdir 'dist/$name-$version': $!";
my $cmd = "tar jcvfh $name-$version.tar.bz2 " . join('', map { "--exclude $_ " } @exclude) . "'$name-$version'";

use Data::Dumper;

if (%include)
  {
    for my $d (keys %include)
      {
        my $td = $d; $td =~ s{^.*/}{};
	mkdir $td;
        my $fglob =  [];
	my $lncmd;

        my $ff = $include{$d};
	$ff = [ $ff ] unless ref $ff;	# promote scalar to ARRAY
	for my $f (@$ff)
	  {
	    if ($d eq '.')
	      {
	        # back up three dir levels: "dist/$name-$version"
	        push @$fglob, "../../$f";
	      }
	    else
	      {
	        # back up three dir levels: "dist/$name-$version/$td"
	        push @$fglob, "../../../$d/$f";
	      }
	  }
	$lncmd = "ln -s @$fglob '$td'";
	print "$lncmd\n";
        system $lncmd and die qq{"$lncmd" failed: $@ $!\n};
      }
    $cmd = "cd .. && $cmd";
  }
else
  {
    $cmd = "ln -f -s ../../* . && cd .. && $cmd";
  }


print "$cmd\n";
system $cmd and die qq{"$cmd" failed: $@ $!\n};
chdir "../..";
system "rm -rf dist/$name-$version; cp '$spec' dist";

