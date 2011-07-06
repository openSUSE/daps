#!/usr/bin/env python
#******************************************************************************\
#* Copyright (c) 2003-2004, Martin Blais
#* All rights reserved.
#* 
#* Redistribution and use in source and binary forms, with or without
#* modification, are permitted provided that the following conditions are
#* met:
#* 
#* * Redistributions of source code must retain the above copyright
#*   notice, this list of conditions and the following disclaimer.
#* 
#* * Redistributions in binary form must reproduce the above copyright
#*   notice, this list of conditions and the following disclaimer in the
#*   documentation and/or other materials provided with the distribution.
#* 
#* * Neither the name of the Martin Blais, Furius, nor the names of its
#*   contributors may be used to endorse or promote products derived from
#*   this software without specific prior written permission.
#* 
#* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#* A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#* OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#* THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#******************************************************************************\

"""optcomplete-simple [<options>]

Test code for optcomplete.  Write some partial arguments and press TAB lots of
times.  See what happens.

"""

__version__ = "$Revision: 1.8 $"
__author__ = "Martin Blais <blais@furius.ca>"

#===============================================================================
# EXTERNAL DECLARATIONS
#===============================================================================

import os
import optparse, optcomplete

#===============================================================================
# LOCAL DECLARATIONS
#===============================================================================

optcomplete.debugfn = '/tmp/optcomplete.log'

#===============================================================================
# MAIN
#===============================================================================

def main():
    parser = optparse.OptionParser()

    parser.add_option('-s', '--simple', action='store_true',
                      help="Simple really simple option without argument.")

    parser.add_option('-o', '--output', action='store',
                      help="Option that requires an argument.")

    opt = parser.add_option('-p', '--script', action='store',
                            help="Option that takes python scripts args only.")
    opt.completer = optcomplete.RegexCompleter('.*\.py')
    
    # Support completion for the command-line of this script.
    optcomplete.autocomplete(parser, ['.*\.tar.*'])

    opts, args = parser.parse_args()
    
    print '----------------------------------------------------------'
    print 'opts', opts
    print 'args', args
    print '----------------------------------------------------------'

if __name__ == '__main__':
    main()
