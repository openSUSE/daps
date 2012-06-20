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


#
# Command line options
#

my $config   = '';
my $help     = '';
my @sections = '';
my $verbose  = 0;

GetOptions (
    'config|c=s'   => \$config,
    'help|h'       => sub { &usage },
    'sections|s=s' => \@sections,
    'verbose|v'    => \$verbose,
);
#
# --sections can either be used multiple times or with a comma
# separated list of sections. In the latter case, we need to
# make a real array out of the comma separated values:
@sections = split(/,/,join(',',@sections));




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
