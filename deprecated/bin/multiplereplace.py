#!/usr/bin/python
# -*- coding: UTF-8 -*-

__author__="Thomas Schraitle <tom_schr@web.de>"
__version__="$Id: multiplereplace.py 2597 2007-04-04 13:37:44Z tom $"

"""Replacing multiple patterns in a single pass
Taken from Python Cookbook,  p.40
"""


import re

class multiplereplace:
    """Replacing multiple patterns in a single pass
    """
    def __init__(self, *args, **kwds):
        self.adict = dict(*args, **kwds)
        self.rx = self.make_rx()

    def make_rx(self):
        """Derive this class and overwrite this method,
        for example to translate by whole words use this:
        class repl_by_whole_words(multiplereplace):
            def make_rx(self):
                return re.compile(r'\b%s\b' % r'\b|\b'.join(map(re.escape,self.adict)))
        """
        return re.compile('|'.join(map(re.escape, self.adict)))

    def one_xlat(self, match):
        return self.adict[match.group(0)]

    def __call__(self, text):
        return self.rx.sub(self.one_xlat, text)


if __name__=="__main__":
    # Be careful:
    # Dictionary and text must have the same encoding!
    umlautmap={
        u"ä": u"ae",
        u"Ä": u"AE",
        u"ü": u"ue",
        u"Ü": u"UE",
        u"ö": u"oe",
        u"Ö": u"OE",
        u"ß": u"ss",
    }
    translate= multiplereplace(umlautmap)
    origstrings = u"Süßstoff Süd Frühling Öffnung Ärger"
    print "Testing multiplereplace..."
    print "Original string: '%s'" % origstrings
    print "Replaced string: '%s'" % translate(origstrings)

#
# EOF