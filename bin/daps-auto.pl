#!/usr/bin/perl -w
# daps-auto.pl ---
# Create documentation output with DAPS and rsync it to given servers
# Needs a config file in ini style, see
# /usr/share/daps/init_templates/daps-auto_sample.ini
#
# Author: Frank Sundermeyer <fsundermeyer@opensuse.org>
# Created: 20 Jun 2012
# Version: 1.0

use warnings;
use strict;
use Getopt::Long;
use Config::IniFiles;
use File::Basename;
use File::Copy;
use File::Path;
use File::Rsync;
use File::Spec::Functions;


my $me = basename($0);
my $builddir      = "";
my $dapsbin       = "/usr/bin/daps";
my $dapsroot      = "";

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

#-------------------------------------------------------------------
# Read config file
#

my $cfg = Config::IniFiles->new( -file => "$config" ) or
    die "\e[31mPlease check the config file syntax.\e[0m\n";

my @dcfiles       = (); # all DC files from one set
my @formats       = (); # all formats from one set
my @sets          = (); # the sections from the config file
my @vformats      = qw(color-pdf epub html htmlsingle pdf txt); # valid formats


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
    rmtree("$builddir");
    mkdir("$builddir",0755);
}


#-------------------------------------------------------------------
# Iterate over sets, DC-files and formats and call daps to create
# the books
#

foreach my $set (@sets) {
    # daps does not like spaces
    my $to_rsync = 0;
    next if "$set" eq "general"; # skip general section
    print "$set:\n";
    if ( $set =~ /.*\s.*/ ) {
        warn "${bcol}Set names must not include whitespace.\n${ecol}Skipping set [$set].\n";
        next
    }
    @dcfiles = split /, */, $cfg->val("$set", 'dcfiles');
    @formats = split /, */, $cfg->val("$set", 'formats');
    my $workdir = $cfg->val("$set", 'workdir');
    # Working Direcory
    if ( ! -d $workdir ) {
        warn "${bcol}Invalid working directory \"$workdir\"in config for section [$set].\n->Skipping set [$set].${ecol}\n";
        next;
    }
    if ( not $nosvnup) {
        print "  Doing an svn up on\n  $workdir\n  " if $verbose;
        system("/usr/bin/svn up $workdir$devnull") == 0
            or warn "${bcol}Failed to svn update $workdir.${ecol}\n";
    }
    # formats
    foreach my $format ( @formats ) {
        if ( ! grep { $_ eq $format } @vformats ) {
            warn "${bcol}Invalid format \"$format\" in config for section [$set].\n-> Skipping ${format}.${ecol}\n";
            next;
        } else {
            foreach my $dcfile ( @dcfiles ) {
                print "  * $dcfile: \U$format...";
                my $dcpath = catfile("$workdir", "$dcfile");
                if ( ! -f $dcpath ) {
                    warn "${bcol}Invalid DC-file \"$dcfile\" in config for section [$set].\n-> Skipping $dcfile${ecol}.\n";
                    next;
                } else {
                    my $dapserror  = '';
                    my $dapsresult = '';
                    my ($dapscmd, $dapslog) = set_daps_cmd_and_log("$set", "$dcpath", "$format");
                    print "\n    Command: $dapscmd\n    Logfile: $dapslog\n" if $verbose;
                    $dapsresult = `$dapscmd`;
                    chomp($dapsresult);
                    $dapserror = $?; # error occurred if != 0
                    
                    if ( $dapserror) {
                        warn "${bcol}Failed to execute\n$dapscmd\nSee $dapslog for details.${ecol}\n";
                        next;
                    } else {
                        $to_rsync = 1;
                        if ( $verbose ) {
                            print "    $dapsresult\n";
                        } else {
                            print "OK\n";
                        }
                        #
                        # Move non-html format results into subdirectory $format
                        #
                        if ( $format !~ /^html.*/ ) {
                            my $resultdir  = dirname($dapsresult);
                            my $format_dir = catdir($resultdir, $format);
                            print "    Moving $dapsresult to $format_dir\n" if $verbose;
                            if ( ! -d $format_dir ) {
                                mkdir($format_dir,0755) or warn "${bcol}Failed to create directory $format_dir.${ecol}\n";
                            }
                            move($dapsresult, $format_dir) or warn "${bcol}Failed to move $dapsresult to $format_dir.${ecol}\n";
                        }
                 
                    }
                }
            }
        }
    }
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
        rsync("$rsync_target", "$rsync_flags", "$set");
    }
    print "\n";
}

#-------------------------------------------------------------------
# Subroutines
#

#-----
# Create the daps command and the logfile location
# according to the data from the logfile
#
sub set_daps_cmd_and_log {
    my ($set, $dcpath, $format) = @_;
    my $bookname;
    my $dapscmd;
    my $dapslog;
    my $set_builddir = catdir($builddir, "$set");

    if ( ! -d $set_builddir ) {
        mkdir($set_builddir, 0755) or die "${bcol}Failed to create directory $set_builddir${ecol}";
    }

    #-------------------
    # daps command
    #
    $dapscmd =  "$dapsbin --builddir=\"$set_builddir\" --docconfig=\"$dcpath\"";
    $dapscmd .= " --dapsroot=\"$dapsroot\"" if $dapsroot ne "";
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

sub rsync {
    #my $rsync = File::Rsync->new( {
    #    archive      => 1,
    #    compress     => 1,
    #    delete       => 1,
    #    exclude      => [ "log/", "DC-*" ],
    #    chmod        => [ "Dg+s" ,"ug+w", "o-w", "o+r", "F-X" ],
    #} );
    
    my ($rsync_target,$rsync_flags, $set) = @_;
    my %rsync_opts = eval $cfg->val('general', 'rsync_flags');
    my $rsync = File::Rsync->new( \%rsync_opts );
    my $rsync_src = catdir("$builddir", "$set");

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
    }
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
