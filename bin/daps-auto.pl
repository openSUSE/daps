#!/usr/bin/perl -w
# daps-auto.pl ---
# Create documentation output with DAPS and rsync it to given servers
# Needs a config file in ini style, see FIXME/sample.ini
#
# Author: Frank Sundermeyer <fsundermeyer@opensuse.org>
# Created: 20 Jun 2012
# Version: 0.01

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
$ENV{SHELL}="/bin/bash";
$ENV{PATH}= ".:/usr/bin:/bin";

#-------------------------------------------------------------------
# Parse Command line options
#

my $clean      = '';
my $config     = '';
my $help       = '';
my $norsync    = 0;
my $nosvnup    = 0;
my @sections   = ();
my $verbose    = '';

GetOptions (
    'clean'        => \$clean,
    'config|c=s'   => \$config,
    'help|h'       => \$help,
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


my $builddir      = "";
my $dapsbin       = "/usr/bin/daps";
my $dapsroot      = "";
my @dcfiles       = (); # all DC files from one set
my @formats       = (); # all formats from one set
my @sets          = (); # the sections from the config file
my @vformats      = qw(color-pdf epub html htmlsingle pdf txt); # valid formats

@sets = $cfg->Sections;

#
# test values and set variables
#

# set buildroot
if ( ! -d $cfg->val('general', 'builddir') ) {
    die "\e[31mInvalid builddir \"$cfg->val(general, builddir)\" in section [general].\e[0m\n"
} else {
    $builddir = $cfg->val('general', 'builddir');
}

# set dapsroot, dapsbin
if ( $cfg->val('general', 'dapsroot') ne "" ) {
    if ( -d $cfg->val('general', 'dapsroot') ) {
        if ( -x "$cfg->val('general', 'dapsroot')/bin/daps" ) {
            $dapsroot = "$cfg->val('general', 'dapsroot')";
            $dapsbin  = "$cfg->val('general', 'dapsroot')/bin/daps";
        } else {
            die "\e[31mdapsroot from section [general] does not contain bin/daps.\e[0m\n"
        }
    } else {
       die "\e[31mInvalid dapsroot in section [general].\e[0m\n" 
    }
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
    next if $set eq "general"; # skip general section
    print "---------- $set ----------\n";
    @dcfiles = split /, */, $cfg->val("$set", 'dcfiles');
    @formats = split /, */, $cfg->val("$set", 'formats');
    my $workdir = $cfg->val("$set", 'workdir');
    # Working Direcory
    if ( ! -d $workdir ) {
        warn "\e[31mInvalid working directory \"$workdir\"in config for section [$set].\n->Skipping complete set [$set].\e[0m\n";
        next;
    }
    if ( not $nosvnup) {
        system("/usr/bin/svn up $workdir >/dev/null 2>&1") == 0
            or warn "\e[31mFailed to svn update $workdir.\e[0m\n";
    }
    # formats
    foreach my $format ( @formats ) {
        if ( ! grep { $_ eq $format } @vformats ) {
            warn "\e[31mInvalid format \"$format\" in config for section [$set].\n-> Skipping $format.\e[0m\n";
            next;
        } else {
            foreach my $dcfile ( @dcfiles ) {
                print "---------- $dcfile: \U$format ----------\n";
                my $dcpath = catfile("$workdir", "$dcfile");
                if ( ! -f $dcpath ) {
                    warn "\e[31mInvalid DC-file \"$dcfile\" in config for section [$set].\n-> Skipping $dcfile\e[0m.\n";
                    next;
                } else {
                    my $dapserror  = '';
                    my $dapsresult = '';
                    my ($dapscmd, $dapslog) = set_daps_cmd_and_log($set, $dcpath, $format);
                    print "$dapscmd\n";
                    print "$dapslog\n";
                    $dapsresult = `$dapscmd`;
                    chomp($dapsresult);
                    $dapserror = $?; # error occurred if != 0
                    
                    if ( $dapserror) {
                        warn "\e[31mFailed to execute\n$dapscmd\nSee $dapslog for details.\e[0m\n";
                        next;
                    } else {
                        print "\e[32m$dapsresult\n\e[0m";
                        #
                        # Move non-html format results into subdirectory $format
                        #
                        if ( $format !~ /^html.*/ ) {
                            my $resultdir  = dirname($dapsresult);
                            my $format_dir = catdir($resultdir, $format);
                            if ( ! -d $format_dir ) {
                                mkdir($format_dir,0755) or warn "\e[31mFailed to create directory $format_dir.\e[0m\n";
                            }
                            move($dapsresult, $format_dir) or warn "\e[31mFailed to move $dapsresult to $format_dir.\e[0m\n";
                        }
                 
                    }
                }
            }
        }
    }
    if ( not $norsync) {
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
        rsync($rsync_target,$rsync_flags, $set);
    }
}

#-------------------------------------------------------------------
# Subroutines
#

#-----
# Create the daps command and the logfile location
# according to the data from the logfile
#
sub set_daps_cmd_and_log {
    my ($set,$dcpath, $format) = @_;
    my $bookname;
    my $dapscmd;
    my $dapslog;
    my $set_builddir = catdir($builddir, $set);

    if ( ! -d $set_builddir ) {
        mkdir($set_builddir, 0755) or die "\e[31mFailed to create directory $set_builddir\e[0m";
    }

    #-------------------
    # daps command
    #
    $dapscmd =  "$dapsbin --builddir=\"$set_builddir\" --docconfig=\"$dcpath\"";
    $dapscmd .= " --dapsroot=\"$dapsroot\"" if $dapsroot ne "";
    $dapscmd .= " $format";
    if ( $format =~ /^html.*/ or $format =~ /.*pdf$/ ) {
        $dapscmd .= " --remarks" if $cfg->val("$set", 'remarks');
        $dapscmd .= " --draft"   if $cfg->val("$set", 'draft');
        $dapscmd .= " --meta"    if $cfg->val("$set", 'meta');
        if ( $format =~ /^html.*/ ) {
            $dapscmd .= " --static";
        }
    }    
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
    my $rsync_src = catdir($builddir, $set);
    
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
        warn "\e[31mFailed to rsnyc $rsync_src to $rsync_target:\n@{$rsync_error}\nrsync command was: @{$rsync_cmd}\e[0m\n";
    }
}


#-----
# Help text
#
sub usage {
    print <<EOF
Usage: $me --config|-c FILE [OPTIONS]

       --clean              : Remove all contents from the builddir specified
                              in the config file
       --config|-c FILE     : Path to config (ini) file
       --help|-h            : This help text
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
