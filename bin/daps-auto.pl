#!/usr/bin/perl -w
# daps-auto.pl ---
# Create documentation output with DAPS and rsync it to given servers
# Needs a config file in ini style, see
# /usr/share/daps/init_templates/daps-auto_sample.ini
#
# Author: Frank Sundermeyer <fsundermeyer@opensuse.org>
# Created: 20 Jun 2012
# Version: 1.1 (12 Jul 2012)

use warnings;
use strict;
use Getopt::Long;
use Config::IniFiles;
use File::Basename;
use File::Copy::Recursive qw(fmove dirmove);
use File::Path qw(make_path remove_tree);;
use File::Rsync;
use File::Spec::Functions;


my $me = basename($0);
my $builddir      = "";
my $dapsbin       = "/usr/bin/daps";
my $dapsroot      = "";
my $to_rsync      = "";
my @vformats      = qw(color-pdf epub html htmlsingle pdf txt); # valid formats

$ENV{SHELL}="/bin/bash";
$ENV{PATH}= ".:/usr/bin:/bin";

#-------------------------------------------------------------------
# Parse Command line options
#

my $clean      = '';
my $config     = '';
my $debug      = '';
my $help       = '';
my $nocolor    = '';
my $norsync    = 0;
my $nosvncheck = 0;
my $nosvnup    = 0;
my @sections   = ();
my $verbose    = '';

GetOptions (
    'clean'        => \$clean,
    'config|c=s'   => \$config,
    'debug'        => \$debug,
    'help|h'       => \$help,
    'nocolor'      => \$nocolor,
    'norsync'      => \$norsync,
    'nosvncheck'   => \$nosvncheck,
    'nosvnup'      => \$nosvnup,
    'sections|s=s' => \@sections,
    'verbose|v'    => \$verbose,
) or usage();

usage() if $help;

# --sections can either be used multiple times or with a comma
# separated list of sections. In the latter case, we need to
# make a real array out of the comma separated values:
@sections = split(/,/,join(',',@sections));

# Check config file
die "\e[31mNo valid config file specified:\n\t $config\e[0m\n" if ! -s $config;

# The ini file containing the SVN revisions:
my $svn_rev_config = $config;
$svn_rev_config =~ s/(.*)\.ini$/$1/;
$svn_rev_config .= "_svn_revisions.ini";

# SetFileName in Config::IniFiles does not work for me, so $rcfg has to be
# initialized with a file. The file must exist, otherwise the object returns
# with an error. Therefor we create an empty file if needed:

unless ( -f "$svn_rev_config" ) {
    open(FH,">$svn_rev_config") or warn "Can't create $svn_rev_config!";
    close(FH);
}
my $rcfg = Config::IniFiles->new( -file => "$svn_rev_config", -allowempty => 1 );


#-------------------------------------------------------------------
# Read config file
#

my $cfg = Config::IniFiles->new( -file => "$config" ) or
    die "\e[31mPlease check the config file syntax.\n@Config::IniFiles::errors\e[0m\n";

my @dcfiles       = (); # all DC files from one set
my @formats       = (); # all formats from one set
my @sets          = (); # the sections from the config file


#
# test values and set variables
#

my $bcol = '';
my $ecol = '';
if ( ! $nocolor ) {
    $bcol = "\e[31m";
    $ecol = "\e[0m";
}

@sets = $cfg->Sections;
if ( @sections ) {
    # sections were specified onm the command line
    foreach my $sect ( @sections ) {
        if ( ! grep { $_ eq $sect } @sets ) {
           die "${bcol}Invalid section specified on the command line.${ecol}\n" 
       }
    }
    @sets = @sections;
}

# set buildroot
$builddir = $cfg->val('general', 'builddir');
if ( ! -d $builddir ) {
    die "${bcol}Invalid builddir \"$builddir\" in section [general].${ecol}\n"
}

# set dapsroot, dapsbin
if ( $cfg->val('general', 'dapsroot') ne "" ) {
    $dapsroot = $cfg->val('general', 'dapsroot');
    if ( -d $dapsroot ) {
        if ( -x "$dapsroot/bin/daps" ) {
            $dapsbin  = "$dapsroot/bin/daps";
        } else {
            die "${bcol}dapsroot \"$dapsroot\" from section [general] does not contain bin/daps.${ecol}\n"
        }
    } else {
       die "${bcol}Invalid dapsroot \"$dapsroot\" in section [general].${ecol}\n" 
    }
}

# verbose settings
my $devnull = "";
$verbose = 1 if $debug;

if ( ! $verbose ) {
    $devnull = " >/dev/null 2>&1";
}

# clean up
if ( $clean ) {
    remove_tree("$builddir");
    mkdir("$builddir",0755);
}


#-------------------------------------------------------------------
# Iterate over sets, DC-files and formats and call daps to create
# the books
#

foreach my $set (@sets) {
    # daps does not like spaces
    my $needs_update = 1; # rebuild docs by default
    my $syncdir  = catdir($builddir, "sync", $set);
    
    next if "$set" eq "general"; # skip general section
    print "$set:\n";

    $to_rsync = 0;
    
    if ( $set =~ /.*\s.*/ ) {
        warn "${bcol}Set names must not include whitespace.\n${ecol}Skipping set [$set].\n";
        next
    }
    @dcfiles = split /, */, $cfg->val("$set", 'dcfiles');
    @formats = split /, */, $cfg->val("$set", 'formats');
    my $workdir      = $cfg->val("$set", 'workdir');
    my $styleroot    = $cfg->val("$set", 'styleroot');
    my $fb_styleroot = $cfg->val("$set", 'fb_styleroot');
    # Working Direcory
    unless ( -d $workdir ) {
        warn "${bcol}Invalid working directory \"$workdir\"in config for section [$set].\n->Skipping set [$set].${ecol}\n";
        next;
    }
    unless ( "$styleroot" ne "" && -d $styleroot ) {
        warn "${bcol}Invalid styleroot directory \"$styleroot\"in config for section [$set].\n->Skipping set [$set].${ecol}\n";
        next;
    }
    unless ( "$fb_styleroot" ne "" && -d $fb_styleroot ) {
        warn "${bcol}Invalid styleroot directory \"$fb_styleroot\"in config for section [$set].\n->Skipping set [$set].${ecol}\n";
        next;
    }    
    unless ( $nosvnup) {
        print "  Doing an svn up on\n  $workdir\n  " if $verbose;
        system("/usr/bin/svn up $workdir$devnull") == 0
            or warn "${bcol}Failed to svn update $workdir.${ecol}\n";
    }
    unless ( $nosvncheck ) {
        $needs_update = check_svn_changes($set, $workdir);
    }
    if ( $needs_update == 0 ) {
        print "  is already up-to-date\n";
        next;
    } elsif ( $needs_update == 2 ) {
        warn "Error on svn checks, rebuilding documents enforced\n";
    }

    # formats
    foreach my $format ( @formats ) {
        if ( not grep { $_ eq $format } @vformats ) {
            warn "${bcol}Invalid format \"$format\" in config for section [$set].\n-> Skipping ${format}.${ecol}\n";
            next;
        } else {
            foreach my $dcfile ( @dcfiles ) {
                print "  * $dcfile: \U$format...";
                my $dcpath  = catfile("$workdir", "$dcfile");
                my $dapscmd = "";
                my $dapslog = "";
                unless ( -f $dcpath ) {
                    # wrong DC file
                    warn "${bcol}Invalid DC-file \"$dcfile\" in config for section [$set].\n-> Skipping $dcfile${ecol}.\n";
                    next;
                } else {
                    # set dapsbin and log file location
                    if ( "$styleroot" ne "" ) {
                        ($dapscmd, $dapslog) = set_daps_cmd_and_log("$set", "$dcpath", "$format", "$styleroot", "$fb_styleroot");
                    } else {
                        ($dapscmd, $dapslog) = set_daps_cmd_and_log("$set", "$dcpath", "$format");                        
                    }
                    my $buildresult = build("$set", "$syncdir", "$format", "$dcpath", "$dapscmd", "$dapslog");
                    # if build was not successful, $buildresult == 0
                    next unless $buildresult;
                }
            }
        }
    }
    # Build sources if source-dc was set
    sources("$set", "$syncdir", "$workdir") if $cfg->exists("$set", 'source-dc');
    if ( not $norsync and $to_rsync ) {
        my $rsync_target;
        my $rsync_flags;
        if ( $cfg->exists("$set", 'rsync_target') ) {
            $rsync_target = $cfg->val("$set", 'rsync_target');
        } else {
            $rsync_target = $cfg->val('general', 'rsync_target');
        }
        if ( $cfg->exists("$set", 'rsync_flags') ) {
            $rsync_flags = $cfg->val("$set", 'rsync_flags');
        } else {
            $rsync_flags = $cfg->val('general', 'rsync_flags');
        }
        rsync("$set", "$rsync_target", "$rsync_flags");
        print "  Rsync complete\n";
    } else {
        print "  Books are available at $syncdir\n";
    }
    print "\n";
}

$rcfg->RewriteConfig;

#-------------------------------------------------------------------
# Subroutines
#


sub check_svn_changes {
    # Arguments (all mandatory):
    #   set    : Section name from config
    #   workdir: absolute path to workdir from config
    #
    # return values:
    #   2 -> error
    #   1 -> revisions differ
    #   0 -> revisions do not differ
    #

    my ($set, $workdir) = @_;
    my $new_revision = '';
    my $svnup_error = '';
    my $section = "Revisions";
    my $key     = "$set" . "_" . "$workdir";
        
    # Do an svn up first, otherwise svn info might not return a correct value
    #
    system("/usr/bin/svn up $workdir$devnull") == 0 or $svnup_error = 1;
    if ( $svnup_error ) {
        warn "${bcol}Failed to svn update $workdir.${ecol}\n";
        return 2;
    }
    # Now get the revision number of $workdir
    #
    $new_revision = `svn info --xml $workdir | xml sel -t -v "/info/entry/commit/\@revision"`;
    chomp($new_revision);
    unless ( $new_revision =~ /^\d+$/) {
        # no integer => error upon looking up revision number;
        return 2;
    }
    if ( -f "$svn_rev_config" and -s "$svn_rev_config" ) {
        if ( $rcfg->exists("$section", "$key") ) {
            my $old_revision = $rcfg->val("$section", "$key");
            if ( $old_revision != $new_revision ) {
                print "SVN revision numbers differ, update needed.\n" if $verbose;
                $rcfg->setval("$section", "$key", "$new_revision");
                return 1;
            } else {
                print "SVN revision numbers are equal, no update needed.\n" if $verbose;
                return 0;
            }
        } else {
            print "SVN revision entry not existing in config, adding it.\n" if $verbose;
            $rcfg->newval("Revisions", "$key", "$new_revision");
            return 1;
        }
    } else {
        print "SVN revision config does not exist, needs to be created\n" if $verbose;
        my @comments = (
            "SVN Revision numbers for $0: $config",
            "-----------------------------------------------------",
            "This file is automatically generated and updated",
            "Please do not modify",
        );
        $rcfg->AddSection("$section");
        $rcfg->SetSectionComment("$section", @comments);
        $rcfg->newval("$section", "$key", "$new_revision");
        return 1
    }
}


#-----
# Create the daps command and the logfile location
# according to the data from the logfile
#
sub set_daps_cmd_and_log {
    # Arguments (all mandatory):
    #   set    : Section name from config
    #   dcpath : absolute path to DC-file
    #   format : sync/ subdirectory name
    #
    # return values:
    # $dapscmd, $dapslog
    #
    my ($set, $dcpath, $format, $styleroot, $fb_styleroot) = @_;
    my $bookname;
    my $dapscmd;
    my $dapslog;
    my $set_builddir = catdir($builddir, "$set");

    # set daps binary to ${dapsroot}/bin/daps if dapsroot is set
    # (otherwise use /usr/bin/daps, see above)
    #
    if ( "$dapsroot" ne "" ) {
        $dapsbin = "${dapsroot}/bin/daps"
    }

    if ( ! -d $set_builddir ) {
        mkdir($set_builddir, 0755) or die "${bcol}Failed to create directory $set_builddir${ecol}";
    }

    #-------------------
    # daps command
    #
    $dapscmd =  "$dapsbin --builddir=\"$set_builddir\" --docconfig=\"$dcpath\"";
    $dapscmd .= " --dapsroot=\"$dapsroot\"" if $dapsroot ne "";
    $dapscmd .= " --styleroot=\"$styleroot\"" if $styleroot ne "";
    $dapscmd .= " --fb_styleroot=\"$fb_styleroot\"" if $fb_styleroot ne "";
    $dapscmd .= " --debug" if $debug; 
    $dapscmd .= " $format";
    if ( $format =~ /^html.*/ or $format =~ /.*pdf$/ ) {
        $dapscmd .= " --remarks" if $cfg->val("$set", 'remarks');
        $dapscmd .= " --draft"   if $cfg->val("$set", 'draft');
        $dapscmd .= " --meta"    if $cfg->val("$set", 'meta');
        if ( $format =~ /^html.*/ ) {
            $dapscmd .= " --static";
        }
    }
    $dapscmd .= " 2>&1" if $debug; 
    #-------------------
    # logfile
    #
    $bookname = basename ($dcpath);
    $bookname =~ s/^DC-//;
    $dapslog = catfile($set_builddir, $bookname, "log", "make_$format.log");
    return ($dapscmd, $dapslog);
}

sub build {
    # Arguments (all mandatory):
    #   set    : Section name from config
    #   syncdir: absolute path to sync/ directory 
    #   format : sync/ subdirectory name
    #   dcpath : absolute path to DC-file
    #   dapscmd: dapscommand tp be executed
    #   dapslog: DAPS log file
    #
    # return values:
    #   0 failure
    #   1 success
    #
    my ($set, $syncdir, $format, $dcpath, $dapscmd, $dapslog) = @_;
    my $dapserror  = '';
    my $dapsresult = '';    
    # ----
    # clean up previous build results
    my ($dapsclean, undef) = set_daps_cmd_and_log("$set", "$dcpath", "clean-results");
    system("$dapsclean clean-results >/dev/null")  == 0
        or warn "${bcol}Failed to run \"$dapsclean\".${ecol}\n";

    # ----
    # build the document
    print "\n    Command: $dapscmd\n    Logfile: $dapslog\n" if $verbose;
    $dapsresult = `$dapscmd`;
    $dapserror = $?; # error occurred if != 0
    chomp($dapsresult);                    
    if ( $dapserror) {
        warn "${bcol}Failed to execute\n$dapscmd\nSee $dapslog for details.${ecol}\n";
        return 0;
    } else {
        my $syncsubdir = "";
        $to_rsync = 1;
        if ( $verbose ) {
            print "    $dapsresult\n";
        } else {
            print "OK\n";
        }
        # --
        # move results into sync subdir
        if ( $format eq "src" ) {
            $syncsubdir = catdir($syncdir, $format);
        } else {
            my $book = basename($dcpath);
            $book =~ s/^DC-//;
            $syncsubdir = catdir($syncdir, $book, $format);
        }
        # If a build was successful, we want to remove the contents of a subdir
        # in sync/ - easiest way is to remove it and create it again
        if ( -d $syncsubdir ) {
            remove_tree("$syncsubdir") or warn "${bcol}Failed to remove sync dir \"$syncsubdir\".\n${ecol}";
        }
        make_path("$syncsubdir", { mode => 0755, }) or warn "${bcol}Failed to create $syncsubdir.${ecol}\n";
        # HTML/HTMLsingle do not return single files, but files and directories
        if ( $format =~ /^html.*/ ) {
            my $resultdir = dirname($dapsresult);
            dirmove($resultdir, $syncsubdir)or warn "${bcol}Failed to move $dapsresult to $syncsubdir.${ecol}\n";
        } else {
            fmove($dapsresult, $syncsubdir) or warn "${bcol}Failed to move $dapsresult to $syncsubdir.${ecol}\n";
        }
    }
    return 1;
}

sub sources {
    # Arguments (all mandatory):
    #   set    : Section name from config
    #   syncdir: absolute path to sync/ directory
    #   workdir: absolute path to workdir from config
    #
    my ($set, $syncdir, $workdir) = @_;
    my $dcfile  = $cfg->val("$set", 'source-dc');
    my $deffile = "";
    my $dcpath  = "";
    my $defpath = "";

    print "  * Creating Source tarball ... ";    

    $dcpath = catfile("$workdir", "$dcfile");
    unless ( -f $dcpath ) {
        warn "${bcol}Invalid source DC-file \"$dcfile\" in config for section [$set].\n-> Skipping source tarball generation.${ecol}.\n";
        return;
    }

    my ($dapscmd, $dapslog) = set_daps_cmd_and_log($set, $dcpath, "package-src");
    
    
    if ( $cfg->exists("$set", 'source-def') ) {
        $deffile = $cfg->val("$set", 'source-def');
        $defpath = catfile("$workdir", "$deffile");
        $dapscmd .= " --def-file=\"$defpath\"";
        unless ( -f $defpath ) {
            warn "${bcol}Invalid source DEF-file \"$defpath\" in config for section [$set].\n-> Skipping source tarball generation.${ecol}.\n";
            return 0;
        }
    }
    # Build the source tarball
    my $buildresult = build("$set", "$syncdir", "src", "$dcpath", "$dapscmd", "$dapslog");
    if ( $buildresult ) {
        return 1; # success
    } else {
        return 0; #failure
    }
}


sub rsync {
    # Arguments (all mandatory):
    #   set         : Section name from config
    #   rsync_target: rsync target from config
    #   rsync_flags : rsync flags from config
    #
    # return values:
    #   0 failure
    #   1 success
    #    
    
    #my $rsync = File::Rsync->new( {
    #    archive      => 1,
    #    compress     => 1,
    #    delete       => 1,
    #    exclude      => [ "log/", "DC-*" ],
    #    chmod        => [ "Dg+s" ,"ug+w", "o-w", "o+r", "F-X" ],
    #} );
    
    my ($set, $rsync_target,$rsync_flags) = @_;
    my %rsync_opts = eval $rsync_flags;
    my $rsync = File::Rsync->new( \%rsync_opts );
    my $rsync_src = catdir("$builddir", "sync", "$set");

    print "  Rsyncing $rsync_src to $rsync_target\n" if $verbose;
    
    # run rsync
    $rsync->exec( {
        src => "$rsync_src",
        dest => "$rsync_target",
    } );

    # check return code
    my $rsync_status = $rsync->status;
    # error handling
    if ( $rsync_status ) {
        my $rsync_error = $rsync->err;
        my $rsync_cmd = $rsync->getcmd( {
            src => "$rsync_src",
            dest => "$rsync_target",
        } );
        warn "${bcol}Failed to rsnyc $rsync_src to $rsync_target:\n@{$rsync_error}\nrsync command was: @{$rsync_cmd}${ecol}\n";
        return 0;
    }
    return 1;
}


#-----
# Help text
#
sub usage {
    print <<EOF;
Usage: $me --config|-c FILE [OPTIONS]

       --clean              : Remove all contents from the builddir specified
                              in the config file
       --config|-c FILE     : Path to config (ini) file
       --debug              : Turn on DAPS debug mode (very verbose). Implies
                              verbose mode.
       --help|-h            : This help text
       --nolocor            : No colored output
       --norsync            : Do not rsync the built documents
       --nosvncheck         : By default, SVN revision numbers of the working
                              directory are compared with the revision numbers
                              from the previous run. If they haven't changed,
                              document building will be skipped. Specify
                              this parameter to skip the SVN check and enforce
                              building.
       --nosvnup            : Do not update the working directory with svn up
       --sections|s SECTIONS: Comma separated list of sections from ini file
                              to use (skip all others). Cann also be specified
                              with multiple instances of --sections:
                              --sections SECT1,SECT2
                              or
                              --sections SECT1 --sections SECT2
       --verbose|-v         : be verbose (DEBUG mode)  
EOF
    exit 0;
    
}




__END__

#=head1 NAME
#
#daps-auto.pl - Describe the usage of script briefly
#
#=head1 SYNOPSIS
#
#daps-auto.pl [options] args
#
#      -opt --long      Option description
#
#=head1 DESCRIPTION
#
#Stub documentation for daps-auto.pl, 
#
#=head1 AUTHOR
#
#Frank Sundermeyer, E<lt>fs@E<gt>
#
#=head1 COPYRIGHT AND LICENSE
#
#Copyright (C) 2012 by Frank Sundermeyer
#
#This program is free software; you can redistribute it and/or modify
#it under the same terms as Perl itself, either Perl version 5.8.2 or,
#at your option, any later version of Perl 5 you may have available.
#
#=head1 BUGS
#
#None reported... yet.
#
#=cut
#
