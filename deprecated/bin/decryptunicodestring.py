#!/usr/bin/python
# -*- coding: utf-8 -*-

""" %(prog)s [String]*

Outputs the Unicode name of each character
"""


import sys
import unicodedata as un


def usage():
   """Prints usage of this script"""
   print __doc__ % { 'prog': sys.argv[0] }
   sys.exit(1)
   

if __name__=="__main__":
   #print ">>", sys.argv

   if len(sys.argv) == 1:
      usage()
   
   if sys.argv[1] in ('-h', '-?', '--help'):
      usage()
      
   for i,n in enumerate(sys.argv[1:]):
        print "%i: '%s'" % (i+1, n)

        # Character = Hex Cat Name
        print "  Char = Hex    Cat  Name"
        for j in unicode(n, 'utf8'):
            print "     %s = U+%04X %s %s" % (j, ord(j), un.category(j), un.name(j))
        print "-"*20

   # sys.exit(0)
