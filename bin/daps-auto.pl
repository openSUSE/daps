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
use File::Spec::Functions;
use Data::Dumper;



my $me = basename($0);
$ENV{SHELL}="/bin/bash";
$ENV{PATH}= ".:/usr/bin:/bin";

#-------------------------------------------------------------------
# Parse Command line options
#

my $config     = '';
my $help       = '';
my @sections   = ();
my $verbose    = '';

GetOptions (
    'config|c=s'   => \$config,
    'help|h'       => \$help,
    'sections|s=s' => \@sections,
    'verbose|v'    => \$verbose,
) or usage();

usage() if $help;

# --sections can either be used multiple times or with a comma
# separated list of sections. In the latter case, we need to
# make a real array out of the comma separated values:
@sections = split(/,/,join(',',@sections));

# Check config file
die "\033[31mNo valid config file specified:\n\t $config\033[0m\n" if ! -s $config;

#-------------------------------------------------------------------
# Read config file
#

my $builddir      = "";
my %config        = ();# all the config file dat
my @config_errors = (); # error messages from config check
my $dapsbin       = "/usr/bin/daps";
my $dapsroot      = "";
my @dcfiles       = (); # all DC files from one set
my @formats       = (); # all formats from one set
my @sets          = (); # the sections from the config file
my @vformats      = qw(color-pdf epub html htmlsingle pdf txt); # valid formats

tie %config, 'Config::IniFiles', (-file => $config ) or
    die "\033[31mPlease check the config file syntax.\033[0m\n";
@sets=tied (%config)->Sections;

#
# test values and set variables
#

# set buildroot
if ( ! -d $config{general}{builddir} ) {
    die "\033[31mInvalid builddir in section [general].\033[0m\n"
} else {
    $builddir = $config{general}{builddir};
}

# set dapsroot, dapsbin
if ( $config{general}{dapsroot} ne "" ) {
    if ( -d $config{general}{dapsroot} ) {
        if ( -x "$config{general}{dapsroot}/bin/daps" ) {
            $dapsroot = "$config{general}{dapsroot}";
            $dapsbin  = "$config{general}{dapsroot}/bin/daps";
        } else {
            die "\033[31mdapsroot from section [general] does not contain bin/daps.\033[0m\n"
        }
    } else {
       die "\033[31mInvalid dapsroot in section [general].\033[0m\n" 
    }
}

#-------------------------------------------------------------------
# Iterate over sets, DC-files and formats and call daps to create
# the books
#

my $dapscmd = "";


$dapscmd = "$dapsbin --vv --builddir=\"$builddir\"";
$dapscmd .= " --dapsroot=\"$dapsroot\"" if $dapsroot ne "";

foreach my $set (@sets) {
    next if $set eq "general"; # skip general section
    print "---------- $set ----------\n";
    @dcfiles = split /, */, $config{$set}{dcfiles};
    @formats = split /, */, $config{$set}{formats};
    # Working Direcory
    if ( ! -d $config{$set}{workdir} ) {
        warn "\033[31mInvalid working directory in config for section [$set].\n->Skipping complete set [$set].\033[0m\n";
        next;
    }
    # DC-files
    foreach ( @dcfiles ) {
        print "---------- $_ ----------\n";
        my $dc = catfile($config{$set}{workdir}, $_);
        my $dc_dapscmd = "$dapscmd";
        if ( ! -f $dc ) {
            warn "\033[31mInvalid DC-file \"$_\" in config for section [$set].\n-> Skipping $_\033[0m.\n";
            next
        } else {
            $dc_dapscmd .= " --docconfig=\"$dc\"";
            # formats
            foreach my $format ( @formats ) {
                my $format_dapscmd = "$dc_dapscmd";
                if ( ! grep { $_ eq $format } @vformats ) {
                    warn "\033[31mInvalid format \"$format\" in config for section [$set].\n-> Skipping $format.\033[0m\n";
                    next;
                } else {
                    $format_dapscmd .= " $format";
                    if ($config{$set}{bookname} ne "") {
                        $dapscmd .= " --name=\"$config{$set}{bookname}\"";
                    }
                    if ( $format =~ /^html.*/ or $format =~ /.*pdf$/ ) {
                        $format_dapscmd .= " --remarks" if  $config{$set}{remarks};
                        $format_dapscmd .= " --draft" if  $config{$set}{draft};
                        $format_dapscmd .= " --meta" if  $config{$set}{meta};
                    }
                    print "$format_dapscmd\n";
                }
            }
        }
    }
}


#-------------------------------------------------------------------

#-----
# Help text
sub usage {
    print <<EOF
Usage: $me --config|-c FILE [OPTIONS]

       --config|-c FILE     : Path to config (ini) file
       --help|-h            : This help text
       --sections|s SECTIONS: Comma seperated list of sections from ini file
                              to use (skip all others). Cann also be specified
                              with multiple instances of --sections:
                              --sections SECT1,SECT2
                              or
                              --sections SECT1 --sections SECT2
       --verbose|-v         : be verbose (DEBUG mode)  
EOF
}




__END__

=head1 NAME

daps-auto.pl - Describe the usage of script briefly

=head1 SYNOPSIS

daps-auto.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for daps-auto.pl, 

=head1 AUTHOR

Frank Sundermeyer, E<lt>fs@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Frank Sundermeyer

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
