package SUSEDOC;

use warnings;
use strict;

use POSIX;	# strftime
BEGIN {
  eval q{ use SVN::Client; };
  eval q{ use XML::Parser; };
};

=head1 NAME

SUSEDOC - The great new SUSEDOC code library. Make make obsolete.

=head1 VERSION

Version 0.08

=cut

our $VERSION = '0.08';


=head1 SYNOPSIS

A library for building susedoc mechanics.

    use SUSEDOC;
    use Data::Dumper;

    my $ctx = SUSEDOC->new( env => '/path/to/en/ENV-file' );
    print Dumper $ctx->env();

    print Dumper $ctx->project_files();

    $p = SUSEDOC::parse_profos('osuse,sles');
    if (SUSEDOC::profiled_ok($p, 'sles;sled')) ...

    ...

SUSEDOC makes use of SVN::Client and XML::Parser, if available. 
Otherwise, you may get runtime errors. 
SVN::Client is provided by the RPM package 'subversion-perl' and the CPAN module 'Alien::SVN'.

=head1 SUBROUTINES/METHODS

=head2 new

Initialize a SUSEDOC object. This object keeps all the context of a book project.
It can be initialized from the existing environment variables C<MAIN>,
C<PROFOS>, C<PRODUCTNAME>, or by specifying an C<env => 'ENV-file'>.
The path where your C<env> is found can be specified as C<XMLDIR>.
Other defaults:
C<verbose => 0, svn_rev => 'WORKING', profos => undef>
C<MAIN> is expected to be in the same directory, as the 'ENV-file', or in a 
subdirectory named 'xml'. The full path leading up to C<MAIN> is stored in C<XMLDIR>.
=cut

sub new 
{
  my $self = shift;
  my $class = ref($self) || $self;
  my %obj = ref $_[0] ? %{$_[0]} : @_;

  # allow '-env' as alternative for 'env'
  for my $k (keys %obj) { $obj{$1} ||= $obj{$k} if $k =~ m{^-(.*)$}; }

  # don't panic, if we don't have SVN::Client loaded...
  local $ENV{HOME} = '/_svn_no_user_';
  $obj{verbose} ||= 0;
  eval { $obj{svn} = new SVN::Client() unless defined $obj{svn} };
  $obj{svn_rev} = 'WORKING'; # or HEAD ??
  if (!$obj{env} and $ENV{MAIN})
    {
      print STDERR "using sourced ENV\n" if $obj{verbose} > 1;
      # export MAIN="MAIN.SLEPOS.xml"
      # export ROOTID="book.slepos"
      # export PROFOS="slepos"
      # export PROFARCH="x86;amd64;em64t"
      # export DISTVER="11"
      # export HTMLROOT="slepos11"
      # export PRODUCTNAME="&slepos;"
      # export PRODUCTNAMEREG="&sleposreg;"
      $obj{env} = { MAIN => $ENV{MAIN}, XMLDIR => '.' };

      if (defined $ENV{PROFOS} and !$obj{profos})
	{
	  print STDERR "profiling with ENV{PROVOS}='$ENV{PROFOS}'\n" if $obj{verbose};
	  $obj{profos} = $ENV{PROFOS};
	}
      print STDERR "using sourced ENV\n" if $obj{verbose} > 1;
    }

  $obj{XMLDIR} ||= $ENV{XMLDIR};

  if ($obj{env} && !ref($obj{env}))
    {
      my %env;
      unless (open IN, "<", $obj{env})
        {
	  die "cannot open env='$obj{env}': $!\n" if $obj{env} =~ m{^/};
	  die "cannot open env='$obj{env}' (and have no XMLDIR): $!\n" 
	  	unless defined $obj{XMLDIR};
	  open IN, "<", "$obj{XMLDIR}/$obj{env}" or 
	  	die "cannot open env='$obj{env}' or $obj{XMLDIR}/$obj{env}: $!\n";
	} 
      my $line = <IN>;
      chomp $line;
      if ($line =~ m{^\s*<})
        {
	  close IN;	# oops looks like an xml file.
	}
      else
        {
          print STDERR "parsing ENV from $obj{env}\n" if $obj{verbose} > 1;
	  my $dir = $obj{env}; $dir =~ s{/*[^/]*$}{}; $dir = '.' if $dir eq '';
	  $obj{env} = { XMLDIR => $dir, ENVFILE => $obj{env} };

	  seek IN, 0, 0;	# rewind
          while (defined(my $line = <IN>))
	    {
	      chomp $line;
	      if ($line =~ m{^export\s+([\w_]+)s*=\s*"?([^"]*)})
		{
		  $obj{env}{$1} = $2;
		}
	    }
          close IN;
	  warn "$obj{env}{ENVFILE} had no 'export MAIN=...' line\n" unless defined $obj{env}{MAIN};

	}

      if (defined $obj{env}{PROFOS} and !$obj{profos})
	{
	  print STDERR "profiling from ENV-file: PROVOS='$obj{env}{PROFOS}'\n" if $obj{verbose};
	  $obj{profos} = $obj{env}{PROFOS};
	}

      if (defined $obj{env}{ROOTID} and !$obj{rootid})
	{
	  print STDERR "rootid from ENV-file: ROOTID='$obj{env}{ROOTID}'\n" if $obj{verbose};
	  $obj{rootid} = $obj{env}{ROOTID};
	}

    }

  if ($obj{env}{MAIN})
    {
      my $m = $obj{env}{MAIN};

      if ($m =~ m{^/})
        {
	  $obj{env}{XMLDIR} = $1 if $m =~ m{^(.*/)};
	}
      else
	{
	  $obj{env}{XMLDIR} ||= '.';
	  $obj{env}{XMLDIR} .= '/xml' unless -f "$obj{env}{XMLDIR}/$m";
	  if ($obj{XMLDIR})
	    {
	      $obj{env}{XMLDIR} = $obj{XMLDIR} unless -f "$obj{env}{XMLDIR}/$m";
	      $obj{env}{XMLDIR} .= '/xml' unless -f "$obj{env}{XMLDIR}/$m";
	      
	    }
	  $obj{env}{MAIN} = $m = "$obj{env}{XMLDIR}/$m";

	  warn "ENV specified a non-existing MAIN: $m\n" 
	    unless -f $m;
	}
    }

  $obj{prof} = parse_profos($obj{profos});
  return bless \%obj, $class;
}

=head2 parse_profos

Parse_profos accepts a semicolon- (or comma-) seperated list of words. 
Each word can be prefixed with '!' or '-' to specify negation. 
The return value is a hash-ref
with C<{neg}> and C<{pos}> subhashes.

Works both, as a class method, or as an object method.
When called, as an object method, it stores the parse result in the object.
=cut
sub parse_profos
{
  my $self = shift @_ if ref $_[0];	# class method, actually.
  my ($profos) = @_;
  return {} unless defined $profos;
  my $prof;
  map { m{^[-!](\S+)} ? $prof->{neg}{$1}++ : $prof->{pos}{$_}++; } split /[;,]/, $profos;

  # sanity check:
  for my $pos (keys %{$prof->{pos}})
    {
      die "parse_profos: os='$pos' is both explicitly included and excluded.\n"
        if $prof->{neg}{$pos};
    }

  $self->{prof} = $prof if defined $self;
  return $prof;
}

=head2 env

Returns a hashref of the environment.
If called with a hash, C<< env(FOO => 'bar') >> merges new values into the
environment.  The special value C<undef> can be used to delete entries.
=cut
sub env
{
  my $self = shift;
  my %hash = (ref $_[0] eq 'HASH') ? %{$_[0]} : @_;
  if (%hash)
    {
      for my $k (keys %hash)
        {
	  if (defined $hash{$k})
	    {
	      $self->{env}{$k} = $hash{$k};
	    }
	  else
	    {
	      delete $self->{env}{$k};
	    }
	}
    }
  return $self->{env};
}

=head2 export_env

Set the global $ENV{} environment of the perl interpreter 
to reflect the contents of the ENV-file.
This helps if you need to run system("make validate");
=cut
sub export_env
{
  my $self = shift;
  for my $k (keys %{$self->{env}})
    {
      $ENV{$k} = $self->{env}{$k};
    }
}

=head2 project_files

Returns the list of all the files belonging to current project.

It is done by recursivly parsing XML files for known references to other files.
It follows C<< <xi:include href=...> >> and finds C<< <imagedata fileref=...> >>
and optionally honors profiling information while doing so.

Optional parameters are: 

 retry_limit => 10	# how often to call prev_file_cmd before failing.
 prev_file_cmd => "svn revert '%s'; svn up -r PREV '%s'"
 orig_file_cmd => "svn up -r HEAD '%s'"
 	# this examle setup catches xml parse errors and 
	# attempts to recover by temporarily 
	# checking out older revisions from svn.
 profos => "-osuse"	# override profiling context from ENV.
 rootid => "part.install"	# override rootid context from ENV.
 type => 'xml'		# filter type xml, default 'all'
 type => 'img'		# filter type img, default 'all'
 type => 'really_all'	# add ENV-files, etc. not impl.
 list => 'files'	# return an array of files only, default hash.

The result list is returned as a hashref. Keys are filenames, relative to
env{XMLDIR}, if applicable. Values are hashes, including the profiling
specification and the xml path in (extended) jquery notation, how the file was referenced.

TODO:
catalogs, Makefiles, ... are not listed here.
recursion into entity-decls does not work.
=cut
sub project_files
{
  my $self = shift;
  my %opt = (ref $_[0] eq 'HASH') ? %{$_[0]} : @_;
  my $old_prof = $self->{prof};
  $self->{prof} = parse_profos($opt{profos}) if $opt{profos};

  eval 
  { 
    use Data::Dumper;
    # don't panic if this fails. 
    # try_parse_xml_file() is protected with evals too.
    $self->{xml} ||= 
      new XML::Parser(Style => 'Tree', NoLWP => 1, NoExpand => 1);
  };

  $self->{files_todo} = [];
  $self->{files_seen} = {};

  my $start = $self->{env}{MAIN};
  die "Cannot start: $start: no such file\n" unless -f $start;

  my $rootid = (defined $opt{rootid}) ? $opt{rootid} : $self->{rootid};
  undef $rootid if defined $rootid and $rootid eq '';

  push @{$self->{files_todo}}, [$start, undef, undef, defined($rootid)?0:1];
  $self->{files_seen}{$start} = { type => 'xml', via => '-', stack => [] };
  $self->{files_seen}{$start}{root_ok} = 1 unless defined $rootid;
  if (defined (my $env = $self->{env}{ENVFILE}))
    {
      $self->{files_seen}{$env} = { type => 'env', via => '-', stack => [] };
      $self->{files_seen}{$env}{root_ok} = 1 unless defined $rootid;
      $self->{files_seen}{$start}{via} = $env;
      $self->{files_seen}{$start}{stack} = [ $env ];
    }

  while (my $file = pop @{$self->{files_todo}})
    {
      print STDERR "entering $file->[0]\n" if $self->{verbose} > 1;
      my ($xml, $msg) = try_parse_xml_file($self, $file->[0], \%opt); 
      unless (defined $xml)
	{
	  $self->{files_seen}{$file->[0]}{msg} = $msg
	    if $self->{files_seen}{$file->[0]};

	  next if $opt{parse_error} and $opt{parse_error}->($self, $file, $msg);
	  warn "Try adding\n\t-prof -$file->[2]{os}\n to the command line to exclude this file.\n"
	    if exists $file->[2]{os};
	  use Data::Dumper;
	  die "try_parse_xml_file failed: ", Dumper $msg, $file;
	}
      print STDERR "$file->[0]: Warning: @{$msg}\n" if $msg and $self->{verbose};
      ## populate $self->{files_seen}
      $self->_find_includes($xml, $file->[0], [ $rootid, $file->[3]||0 ] );
    }

  my $r;
  
## this is a hack.
## not good, we should push entity_files on files_todo, so that we recurse into them.
#  for my $e (keys %{$self->{entity_files}})
#    {
#      my $ee = ($e =~ m{^/}) ? $e : "$self->{env}{XMLDIR}/$e";
#      $self->{files_seen}{$ee} = { type => 'ent', root_ok => 1, via => '', os => {} };
#    }

  ## make paths relative, where possible, honor rootid.
  my $not_in_root = 0;
  for my $k (keys %{$self->{files_seen}})
    {
      my $f = $k; $f =~ s{^\Q$self->{env}{XMLDIR}\E/*}{};
      next if $opt{type} and $opt{type} ne $self->{files_seen}{$k}{type};
      next unless $self->{files_seen}{$k}{root_ok};

      $r->{$f} = $self->{files_seen}{$k};
      $r->{$f}{via} =~ s{^\Q$self->{env}{XMLDIR}\E/*}{} if defined $r->{$f}{via};
    }

  if ($self->{verbose} and scalar(keys %$r) < scalar(keys %{$self->{files_seen}}))
    {
      print STDERR "ignored %d of %d files due to type or rootid filter.\n",
	scalar(keys %{$self->{files_seen}})-scalar(keys %$r),
	scalar(keys %{$self->{files_seen}});
    }

  #destructor
  $self->{prof} = $old_prof;
  delete $self->{files_seen};
  delete $self->{files_todo};

  return [ keys %$r ] if $opt{list}||'' eq 'files';
  return $r;
}

## private recursion helper for project_files()
## $via->[0] is the filename, subsequent elements are nodes in the file.
sub _find_includes
{
  my ($self, $tree, $via, $rootid, $node) = @_;
  $via = [ $via ] unless ref $via;
  my $filename = $via->[0];
  die "_find_includes($filename): tree is not an ARRAY-ref\n" unless ref $tree eq 'ARRAY';
  $node ||= '';
  my $dir = $filename; $dir =~ s{/*[^/]*$}{}; $dir = '.' if $dir eq '';
  my $newnode;

  my $root_id;
  my $root_ok;
  if ($rootid)
    {
      if (ref $rootid)
        {
	  $root_id = $rootid->[0];
          $root_ok = $rootid->[1];
	}
      else
        {
	  $root_id = $rootid;
	  $root_ok = 0;
	}
    }
  $root_ok = 1 unless defined $root_id; 	# no filter, include all.

  # the tree has 
  #  scalars followed by arrays: The scalar is a node name, the array its contents.
  #  hashes as first elements in an array: this is the attributes of a node.
  my $i;
  for ($i = 0; $i <= $#$tree; $i++)
    {
      my $e = $tree->[$i];

      unless (ref $e) { $newnode = $e; next }	
      if (ref $e eq 'ARRAY' and defined $newnode)
        {
	  ## root_ok == 2 means: inherited from parent file.
	  $self->_find_includes($e, [ @$via, "[$i;$newnode]" ], [ $root_id, $root_ok ], $newnode);
	}
      elsif (ref $e eq 'HASH')
        {
	  ## this is found near the beginning of book_opensuse_startup.xml:
	  # <?provo dirname="startup/"?>
	  # <book lang="en" id="book.opensuse.startup" role="print">
	  #  <bookinfo>
	  #
	  ## FIXME: how do we match IDs? Case insensitiv? wildcards?
	  if (defined($e->{id}) and defined($root_id) and $e->{id} eq $root_id)
	    {
	      $root_ok = 2;
	      ## we have prepared the stack of files leading up to the root_id 
	      ## node, flag them with -1. This means that the file itself is needed,
	      ## but it should not inherit the property to any children.
	      for my $f (@{$self->{files_seen}{$filename}{stack}})
	        {
		  print STDERR "leading up to root_id: $f\n" if $self->{verbose} > 1;
		  $self->{files_seen}{$f}{root_ok} = -1;
		}
	      $self->{files_seen}{$filename}{root_ok} = 1;
	      print STDERR "$root_id $e->{id} in $filename\n" if $self->{verbose} > 1;
	    }

	  if ($node eq 'xi:include')
	    {
	      # FIXME: profiling works on any node, seen once, effective downwards.
	      ## CAUTION: keep in sync with Entity handler in try_parse_xml_file();
	      die Dumper $filename, $node, $e, "node has no href" unless exists $e->{href};
	      my $href = $e->{href};
	      $href = $dir . '/' . $href unless $href =~ m{^(/|\w+://)};
	      if ($self->profiled_ok($e->{os}, $href))
	        {
		  print STDERR "adding xml $href\n" if $self->{verbose} > 1;
		  # a file may profile differently, in different include statements,
		  # it may be within or without of the rootid. 
		  # So we need to redo any files that have not yet contributed to the rootid.
	          push @{$self->{files_todo}}, [ $href, $filename, $e, $root_ok ] 
		    unless defined $self->{files_seen}{$href} and
		                   $self->{files_seen}{$href}{root_ok};

		  $self->{files_seen}{$href}{type} = 'xml';
		  $self->{files_seen}{$href}{via} = join '', @$via;
		  $self->{files_seen}{$href}{os}{$e->{os}||'*'}++;
		  $self->{files_seen}{$href}{root_ok} = $root_ok;
		  $self->{files_seen}{$href}{stack} = 
		    [ 
		      @{$self->{files_seen}{$filename}{stack}}, 
		      $filename
		    ];
		}
	    }
	  elsif ($node eq 'imagedata')
	    {
	      die Dumper $filename, $node, $e, "node has no fileref" unless exists $e->{fileref};
	      my $fmt = lc $e->{format} || 'png';
	      my $fileref = $e->{fileref};
	      #
	      # <imageobject role="fo">
	      #   <imagedata fileref="sled10_ad_schema.svg" width="75%" format="SVG"/>
	      # </imageobject>
	      # <imageobject role="html">
	      #   <imagedata fileref="sled10_ad_schema.png" width="75%" format="PNG"/>
	      # </imageobject>
	      #
              unless ($fileref =~ m{^(/|\w+://)})
	        {
	          my $file = $dir . "/../images/gen/$fmt/" . $fileref;
		  unless (-f $file)
		    {
	              $file = $dir . "/../images/src/$fmt/" . $fileref;
		    }
		  $fileref = $file;
		}
	      if ($self->profiled_ok($e->{os}) && $root_ok)
	        {
		  $self->{files_seen}{$fileref}{type} = 'img';
		  $self->{files_seen}{$fileref}{os}{$e->{os}||'*'}++;
		  $self->{files_seen}{$fileref}{via} = join '', @$via;
		  $self->{files_seen}{$fileref}{root_ok} = $root_ok;
		}
	    }
	}
    }
}

=head2 profiled_ok

Tests a semicolon- (or comma-) seperated profiling info against the current context.
Returns 1 if it matches, 0 otherwise. 

Works both, as a class method, or as an object method.
Pass the return value of parse_profos() as first parameter, to use this 
as a class method.

=cut
sub profiled_ok
{
  my ($self, $os) = @_;
  my $prof = $self->{prof} || $self;
  return 1 unless defined $os;	# this object is unprofiled
  return if $os eq '';		# this object is unprofiled

  my $pos = 0;
  my $neg = 0;
  for my $o (split /[,;]/, $os)
    {
      $pos++ if $prof->{pos}{$o};
      $neg++ if $prof->{neg}{$o};
    }

  return 1 if $pos;
  return 0 if $neg;
  return ($prof->{pos} and scalar(keys %{$prof->{pos}})) ? 0 : 1;
}


=head2 file_prop_info

Returns svn properties (and svn info) of a file. If the given file is a relative path, and and environment context is intitialized, the file is interpreted relative to the XMLDIR.
If no C<$propnames> list is given, all properties are returned. C<$propnames>
can be specified as an array-ref or a regexp or undef.  Svn info are mapped to
properties with a 'svn:info:' prefix.  This method can also be called as a
class method like C<SUSEDOC::file_prop_info('svn_filename')>. 

It does not access the network.
It can be used to implement dmstat.
Returns a hashref of the files properties.
=cut

sub file_prop_info 
{
  my ($ctx, $file, $propnames) = @_;
  ($ctx, $file, $propnames) = ({}, @_) unless ref $ctx;

  $file = "$ctx->{env}{XMLDIR}/$file" if
    $ctx->{env} and $ctx->{env}{XMLDIR} and $file !~ m{^/};
  
  $propnames = '^.*$' unless defined $propnames;
  $propnames = "^(\Q" . join("\E|\Q", @$propnames) . "\E)\$" if ref $propnames eq 'ARRAY';

  local $ENV{HOME} = '/_svn_no_user_';
  $ctx->{svn} = new SVN::Client() unless defined $ctx->{svn};
  # my $rev = $ctx->{svn_rev} || 'WORKING';
  my $l = $ctx->{svn}->proplist($file, undef, 0);
  my $h = $l->[0]->prop_hash();

  my $info;
  $ctx->{svn}->info($file, undef, undef, sub { $info = $_[1]; }, 0);
  $h->{'svn:info:rev'} = $info->rev;
  $h->{'svn:info:url'} = $info->URL;
  $h->{'svn:info:last_changed_rev'}       = $info->last_changed_rev;
  $h->{'svn:info:last_changed_date_usec'} = $info->last_changed_date;
  $h->{'svn:info:last_changed_date'}      = strftime "%F %T %z", localtime($info->last_changed_date/1000000);
  $h->{'svn:info:last_changed_author'}    = $info->last_changed_author;
  if ($info->has_wc_info)
    {
      $h->{'svn:info:text_time_usec'} = $info->text_time;
      $h->{'svn:info:text_time'}      = strftime "%F %T %z", localtime($info->text_time/1000000);
      $h->{'svn:info:prop_time_usec'} = $info->prop_time;
      $h->{'svn:info:prop_time'}      = strftime "%F %T %z", localtime($info->prop_time/1000000);
      $h->{'svn:info:checksum'}       = $info->checksum;
    }

  my $r;
  for my $k (keys %{$h})
    {
      $r->{$k} = $h->{$k} if $k =~ m{$propnames};
    }
  return $r;
}

=head2 try_parse_xml_file

Runs an xml parser on the specified file, optionally 
calling prev_file_cmd shell commands, to locate a version of the file that parse successfully.

=cut

sub try_parse_xml_file
{
  my ($self, $filename, $opt) = @_;
  $opt->{retry_limit} = 100 unless defined $opt->{retry_limit};
  my $xp = $self->{xml};

  my $xml;
  my @msg;
  my $retry = 0;
  for (;;)
    {
      $xml = '';
      return (undef, [ "Cannot read $filename: $!" ])
        unless (open XML, "<", $filename);
      
      ####
      # Entity(Expat, Name, Val, Sysid, Pubid, Ndata, IsParam)
      # For external entities, the Val parameter will be undefined, 
      # the Sysid parameter will have the system id, ..
      $self->{xml}->setHandlers('Entity' => sub
        { 
	  my ($p, $n, $val, $sysid) = @_;
	  unless ($val || (defined $self->{files_seen}{$sysid} and
	                           $self->{files_seen}{$sysid}{root_ok}))
	    {
	      # yes, it is an exteral entity file, and it is new.

	      ## CAUTION: keep in sync with if ($node eq 'xi:include') in _find_includes().
              my $dir = $filename; $dir =~ s{/*[^/]*$}{}; $dir = '.' if $dir eq '';

              my $ent_file = $sysid;
	      $ent_file = $dir . '/' . $ent_file unless $ent_file =~ m{^(/|\w+://)};
	      ### FIXME: try_parse_xml_file fails on entity files
	      ## syntax error at line 6, column 0, byte 242:
	      ## <!ENTITY exampleuser    "tux">
	      ## ^
              # push @{$self->{files_todo}}, [$ent_file, $filename, undef, 1];
	      $self->{files_seen}{$ent_file} = { type => 'ent', via => $filename, root_ok => 1 };
	    }
	});

      $xml = eval { $xp->parse(*XML, ErrorContext => 3) };
      if ($@)
        {
	  push @msg, $@;

          close(XML);
	  return (undef, @msg) if $opt->{retry_limit} and $opt->{retry_limit} < ++$retry;
	  return (undef, @msg) unless defined $opt->{prev_file_cmd};
	  my $cmd = sprintf $opt->{prev_file_cmd}, $filename, $filename;
          print "$cmd\n" if $self->{verbose};
	  system $cmd and return (undef, [@msg, "recover helper($cmd) failed: $!\n"]);
	  next;
	}
      close(XML);
      last;
   }
  return ($xml, undef) unless @msg;

  if ($opt->{orig_file_cmd})
    {
      my $cmd = sprintf $opt->{orig_file_cmd}, $filename, $filename;
      print "$cmd\n" if $self->{verbose};
      system $cmd and push @msg, "cleanup helper($cmd) failed: $!\n";
    }
  return ($xml, [@msg, sprintf "\nResolved after %d retries.", scalar(@msg)]);
}

sub _collect_subkeys
{
  my ($hash) = @_;

  my %k;
  for my $s (values %$hash)
    {
      for my $k (keys %$s)
	{
	  $k{$k}++;
	}
    }
  return [sort keys %k];
}

=head2 dmstat_fmt_xml

Format the output of (multiple) file_prop_info() calls as an XML document.
Takes a hash of such outputs as first parameter, with the respective filenames
as keys.  Takes an optional second parameter, list_only, which if nonzero,
formats a much simpler XML file, which lists only the used property names.
Returns an XML document.

=cut
sub dmstat_fmt_xml
{
  my ($self, $stat, $list_only) = @_;
  my $text = qq{<?xml?>\n<dmstat version="$VERSION">\n};

  my $p = _collect_subkeys($stat);
  if ($list_only)
    {
      map { $text .= qq{ <property name="$_"/>\n} } (@$p);
    }
  else
    {
      for my $file (sort keys %$stat)
	{
	  my $s = $stat->{$file};
	  my $svn='';
	  my $doc='';
	  my $els='';
	  for my $k (@$p)
	    {
	      next unless defined $s->{$k};
	      if    ($k =~ m{^doc:(.*)}) { $doc .= qq{ $1="$s->{$k}"}; }
	      elsif ($k =~ m{^svn:(.*)}) { $svn .= qq{ $1="$s->{$k}"}; }
	      else                       { $els .= qq{ $k="$s->{$k}"}; }
	    }
	  $text .=  qq{ <file name="$file"$els}.(($svn or $doc)?qq{>\n}:qq{/>\n});
	  $text .=  qq{  <svn$svn/>\n} if $svn;
	  $text .=  qq{  <doc$doc/>\n} if $doc;
	  $text .=  qq{ </file>\n} if $svn or $doc;
	}
    }
  $text .= "</dmstat>\n";
  return $text;
}

=head2 find_image_files

Susedoc references images as images/src/{png,svg,fig}/file.{png,svg,fig}
although the files do not actually exist under this path.
Candidate paths are images/{print,online}/file.{png,svg,fig}.
find_image_files() returns a list of existing paths, that match the given path.
Relative to XMLDIR, if possible.

=cut

sub find_image_files
{
  my ($self, $imgname) = @_;

  my @dirs = qw( print online gen/png gen/svg );
  my $xmldir = '';
  $xmldir = "$self->{env}{XMLDIR}/" if $self->{env} and defined $self->{env}{XMLDIR};

  return $imgname if -f $imgname or -f $xmldir.$imgname;

  my @files;

  if ($imgname =~ m{^(.*/images/)src.*?(/[^/]+)$})
    {
      my ($p1, $p2) = ($1, $2);
      for my $d (@dirs)
        {
	  my $f = $p1.$d.$p2;
	  push @files, $f if -f $f or $xmldir.$f;
	}
      return @files;
    }
  else
    {
      # not parsable.
      return $imgname;
    }
}

=head1 AUTHOR

Juergen Weigert, C<< <jw at suse.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-susedoc at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=SUSEDOC>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc SUSEDOC


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=SUSEDOC>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/SUSEDOC>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/SUSEDOC>

=item * Search CPAN

L<http://search.cpan.org/dist/SUSEDOC/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Juergen Weigert.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of SUSEDOC
