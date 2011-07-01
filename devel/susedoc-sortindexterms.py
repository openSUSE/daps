#!/usr/bin/python
# -*- coding: UTF-8 -*-
"""
  %prog -- Sorts indexterms and outputs an XML file
  
  This script reads in an IDX file, sorts it and writes an IND file.
  The IDX file have the following structure:
  
  <index>
     <title>...</title>
     <indexentry>
        <primaryie>
           <phrase>...</phrase>
           <phrase role="key">...</phrase>
           <phrase role="sortas">...</phrase>
        </primaryie>
        <secondaryie>
           <phrase>...</phrase>
           <phrase role="key">...</phrase>
           <phrase role="sortas">...</phrase>
        </secondaryie>
        <tertiaryie>
           <phrase>...</phrase>
           <phrase role="key">...</phrase>
           <phrase role="sortas">...</phrase>
        </tertiaryie>
  </index>


  After the sorting and grouping, the IND file has the following structure:
 
  <index id="index">
    <title>Index</title>
    <indexdiv>
      <title>A</title>
      <indexentry>
        <primaryie>
          <phrase>...</phrase>
        </primaryie>
        <secondaryie>
           <phrase>...</phrase>
           <phrase role="key">...</phrase>
        </secondaryie>
        <!-- ... more than one secondaryie ... -->
        <tertiaryie>...</tertiaryie>
      </indexentry>
      <!-- ... more than one indexentry ... -->
    </indexdiv>
    <!-- ... more than one indexdiv ... -->
   </index>
"""

__version__ = "$Revision: $"[11:-2]
__author__="Thomas Schraitle <thomas DOT schraitle AT suse DOT de>"
__license__="GPL"

import sys
import os.path
import locale
import unicodedata
import types
import logging
from pprint import pprint as pp

import itertools

from lxml import etree as ET
from optparse import OptionParser
#from StringIO import StringIO


class Indexterm:
   """Class which holds the primary, secondary and tertiary keys as well
      as the keys to render it.
      Supports localized sorting based on locale.strcoll()
   """
   def __init__(self, indexentry, encoding="UTF-8"):
     """Constructor"""
     self.encoding = encoding
     self.ie = indexentry
     __t=type(indexentry)
     assert ElementType == __t, "Indexterm: Expected Element type but got %s" % __t
     assert indexentry.tag == "indexentry", "Indexterm: Expected Element indexentry got '%s'" % indexentry.tag
     # -----------------------------
     # Better method of getting the text?
     self.sortkey = []
     self.renderkey = []
     self.primarysee = None
     p, s, t = 3*['']
     for i in indexentry.getchildren():
       # print i
       if i.tag == "primaryie":
          p = conv2unicode(flatten(i).strip())
          assert p != '', "Got empty primary."
          p = conv2unicode(i.xpath("phrase[not(@role)]")[0].text.strip() )
          logging.debug("XPath: %s" % p )
       elif i.tag=="secondaryie":
          s = conv2unicode(i.xpath("phrase[not(@role)]")[0].text.strip())
       elif i.tag=="tertiaryie":
          t = conv2unicode(i.xpath("phrase[not(@role)]")[0].text.strip())
       else:
         # print ">>>", i.tag
         logging.warning("  indexentry contains '%s' tag in '%s' (unsupported)" % (i.tag, p) )
     # print "Indexentry: %s/%s/%s" % (repr(p), repr(s), repr(t) )

     idxchildren=indexentry.getchildren()
     sortas=[]
     for i in idxchildren:
       # print i
       pathres = i.xpath("phrase[@role='sortas']")
       if pathres:
         sortas.append(pathres[0].text.strip())
         logging.debug("Indexentry: Found @sortas '%s'" % pathres[0].text.strip())
       else:
         sortas.append(None)

     #self.renderkey = [p,s,t]
     #self.sortkey   = [ p, s, t ]
     logging.debug("Indexentry: Considering @sortas..." )
     for index,item in enumerate([p,s,t]):
         x = list_get(sortas, index)
         if x:
           self.sortkey.append(x)
           self.renderkey.append(item)# Use item for display
         else:
           self.sortkey.append(item)
           self.renderkey.append(item)

     logging.debug("Indexentry: sortkey=%s" % self.sortkey )
     logging.debug("Indexentry: renderkey=%s" % self.renderkey )

     self.cmpstring = " ".join(self.sortkey).strip()
     #

     # The next variables are filled by __decomp():
     self.firstchar = None
     self.decomposed = None
     self.firstchardecomposed = None
     self.category=None
     # Use the sortkey for decomposition:
     self.__decomp(self.sortkey[0],
                   self.sortkey[1],
                   self.sortkey[2], encoding)
     logging.debug("  firstchar=%s" % self.firstchar )
     logging.debug("  decomposed=%s" % self.decomposed )
     logging.debug("  category=%s" % self.category )
     logging.debug("  firstchardecomposed=%s" % self.firstchardecomposed )


   def __decomp(self, primary, secondary, tertiary, encoding):
     """Decomposite a primary, secondary or tertiary"""
     self.firstchar = conv2unicode(primary)[0].upper()
     self.decomposed = unicodedata.decomposition(self.firstchar)
     self.category=unicodedata.category(self.firstchar)
     self.firstchardecomposed=None

     if self.decomposed=='':
       self.decomposed=self.firstchar
       self.firstchardecomposed=self.firstchar
     else:
       # print "## %s -> %s" % (self.decomposed.split()[0], int(self.decomposed.split()[0], 16))
       self.decomposed=unichr(int(self.decomposed.split()[0], 16))
       self.firstchardecomposed=self.decomposed

   def __cmp__(self, other):
     """Compare localized"""
     return locale.strcoll(self.cmpstring, other.cmpstring)

   def __repr__(self):
     return "<Indexterm(\"%s\")>" % ( self.sortkey )

   def __str__(self):
     return "Indexterm: %s" % self.sortkey
     #return conv2unicode(u"%s || %s" % (
             #u" > ".join(self.sortkey),
             #u" > ".join(self.renderkey)
             #))

   def __getattr__(self, name):
     if name=="primary":
       return self.sortkey[0]
     elif name=="secondary":
       return self.sortkey[1]
     elif name=="tertiary":
       return self.sortkey[2]
     elif name=="p":
       return self.renderkey[0]
     elif name=="s":
       return self.renderkey[1]
     elif name=="t":
       return self.renderkey[2]
     else:
       raise AttributeError("class Indexterm has no attribute '%s'" % name)

class Indexdict(object):
   """A class for iterating over sorted indexes"""
   def __init__(self, d, sort=True):
      assert isinstance(d, dict), "Expected a dictionary."
      self.idxdict = d
      self.sort = sort

   def __iter__(self):
      keys = self.idxdict.keys()
      return iter( self.generate_key(keys) )

   def generate_key(self, keys):
      if self.sort:
         keys.sort(cmp=locale.strcoll)
      return [(key, self.idxdict[key]) for key in keys]

   def __repr__(self):
      return "<%s %s>" % (self.__class__, self.idxdict)

class IndexdictSpecial(Indexdict):
   """Takes care of Numbers and Symbols"""
   def __init__(self, d, sort=True):
      self.base = super(IndexdictSpecial, self).__init__(d, sort)

   def __iter__(self):
      # Take care of correcting order
      keys = self.idxdict.keys()
      if self.sort:
         keys.sort(cmp=locale.strcoll)
      if "Numbers" in keys:
        keys.remove(u"Numbers")
        keys.insert(0, u"Numbers")
      if "Symbols" in keys:
        keys.remove(u"Symbols")
        keys.insert(0, u"Symbols")
      return iter( self.generate_key(keys) )


# Global variables
VERBOSE=None

# Types
ElementType=type(ET.Element("a"))


def debugmsg(*msg):
  if VERBOSE:
    print >> sys.stdout, msg[0]

def debuginlinemsg(*msg):
  if VERBOSE:
    print >> sys.stdout, " ".join(msg),

def flatten(elem, include_tail=0):
    """Recursively extract text content."""
    text = elem.text or ""
    for e in elem:
        text += flatten(e, 1)
    if include_tail and elem.tail: text += elem.tail
    return text


def list_get(L, i, v=None):
    """Returns an element of a list if it exists
    Taken from recipes 4.3, p.153 of Python Cookbook 2nd edition
    """
    if -len(L) <= i < len(L): return L[i]
    else: return v


def conv2unicode(text, encoding="UTF-8"):
  """Converts a text into a unicode string (default UTF-8 encoding)"""
  if type(text) == types.UnicodeType:
    return text
  else:
    return unicode(text, encoding)

LANGUAGES={
 "cs": "cs_CZ",
 "de": "de_DE",
 "da": "da_DK",
 "en": "en_US",
 "es": "es_ES",
 "fr": "fr_FR",
 "hu": "hu_HU",
 "it": "it_IT",
 "ru": "ru_RU",
}


def groupkeyfunc(name):
    """Returns the key for grouping """
    category=name.category

    # print "Name: %s, category: %s" % (name, category)
    if category.startswith('L'): # _L_etters
        return name.firstchardecomposed
    elif category.startswith('N'):
        return u"Numbers"
    elif category.startswith('P') or category.startswith('S'):
        return u"Symbols"
    # Maybe we need to check for more categories
    else:
        return u"Symbols"



if __name__=="__main__":
    parser = OptionParser(__doc__)
    parser.add_option("-l", "--language",
      dest="lang",
      help="Sort with give language (ISO code)",
    )
    parser.set_defaults(encoding="UTF-8")
    parser.add_option("-e", "--encoding",
      dest="encoding",
      help="Use the following encoding",
    )
    parser.set_defaults(verbose=True)
    parser.add_option("-q", "--quiet",
      action="store_false",
      dest="verbose",
      help="don't print status messages to stdout"
    )
    parser.add_option("-v", "--verbose",
      action="store_true",
      dest="verbose",
      help="print status messages to stdout"
    )

    parser.add_option("-o", "--output",
      dest="output",
      help="Saves file to OUTPUT (otherwise stdout)"
    )

    # Parse the command line:
    (options, args) = parser.parse_args()
    if not args:
        parser.print_help()
        sys.exit(1)

    VERBOSE=options.verbose
    # LOGGING=options.logging

    debugmsg(options, args )
    defaultlocale = locale.setlocale(locale.LC_COLLATE, "")
    if options.lang == None:
       options.lang = defaultlocale
    else:
       # Check for case where only two letters are used:
       if len(options.lang)==2:
         options.lang = "%s.%s" % (LANGUAGES[options.lang], options.encoding)

       try:
           locale.setlocale(locale.LC_COLLATE, options.lang)
       except locale.Error, e:
            print >> sys.stderr, "ERROR: %s: '%s'" % (e, options.lang)
            sys.exit(100)

    debugmsg("  Using language %s" % options.lang )

    log="".join( [args[0].rsplit(".",1)[0], ".log" ])
    debugmsg("  Logging into '%s'" % log )
    logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(levelname)s %(message)s',
                    filename=log,
                    filemode='w')
    logging.debug("Used Language: %s" % options.lang)

    # Step 1: Read in the generated IDX file
    logging.info("Step 1: Reading in the idx file '%s'..." % args[0])
    Tree = ET.parse(args[0])
    Root = Tree.getroot()
    indextitle = Root.xpath("title")[0].text

    logging.info("Step 2: Preparing idxlistgen.")
    idxlist = map(Indexterm, Root.xpath("indexentry") )
    idxlistgen = itertools.ifilter(bool, idxlist)

    indexdivs={}
    logging.info("Step 3: Iterating through idxlistgen and preparing indexdiv dictionary for grouping.")
    for i in idxlistgen:
      if type(i) == types.NoneType:
        continue # We don't want nothing, so investigate next item

      divkey = groupkeyfunc(i)
      primkey, seckey, tertkey = i.sortkey
      indexdivs.setdefault(divkey, {})
      indexdivs[divkey].setdefault(primkey, {})
      # Grouping
      if seckey:
        indexdivs[divkey][primkey].setdefault(seckey, []).append(i)
      else:
        # Use an empty string to mark an empty secondary
        indexdivs[divkey][primkey].setdefault('', []).append(i)
    # At the end the dictionary indexdivs contains the following
    # structure:
    # FIXME

    logging.info("Step 4: Generating index body...")
    Root = ET.Element("index")
    Root.attrib["id"]="index"
    Title = ET.SubElement(Root, "title")
    if indextitle:
      Title.text = indextitle
    else:
      Title.text = u"Index"

    debuginlinemsg(" ")
    for divkey, divrest in IndexdictSpecial(indexdivs):
      debuginlinemsg("[%s]" % divkey )
      logging.info("Grouping %s..." % divkey)
      Idxdiv = ET.SubElement(Root, u"indexdiv")
      Idxtitle = ET.SubElement(Idxdiv, u"title")
      Idxtitle.text = divkey
      if divkey=='Numbers' or divkey=='Symbols':
        Idxdiv.attrib["role"]=divkey.lower()

      for primkey, primrest in Indexdict(divrest):
        logging.info("  Primary %s" % primkey)
        Indexentry = ET.SubElement(Idxdiv, u"indexentry")
        Primaryie = ET.Element(u"primaryie")
        Phrase = ET.SubElement(Primaryie, u"phrase")
        Phrase.text = primkey
        Indexentry.append(Primaryie)

        for secondarykey, secrest in Indexdict(primrest):
          logging.info("    Secondary %s" % secondarykey)
          seeelements=secrest[0].ie.xpath("seeie|seealsoie")
          # tertiaryelements =
          if not secondarykey:
            # There is no secondary, so use just the primaryie
            # print "  *",
            # pp(secrest)
            for s_ in secrest:
              _ = s_.ie.xpath("primaryie/phrase[@role='key' or @role='sortas']")
              for ss in _:
                 Primaryie.append(ss)
          else:
            #print "... '%s' > " % secondarykey, secrest
            # pp(secrest)
            Secondaryie = ET.Element(u"secondaryie")
            Phrase = ET.SubElement(Secondaryie, u"phrase")
            Phrase.text = secondarykey
            Indexentry.append(Secondaryie)

            if secrest != []:
               secrest.sort()

            for tert in secrest:
               _ = tert.ie.xpath("secondaryie/phrase[@role='key' or @role='sortas']")
               for tt in _:
                  Secondaryie.append(tt)

               t = tert.ie.xpath("tertiaryie")
               if t != []:
                  #print "*", t
                  logging.info("      Tertiary %s" % t)
                  Indexentry.append(t[0])

          if seeelements != []:
            for see in seeelements:
              Indexentry.append(see)


    # Now it's time to save our work...
    if options.output == None:
        print >> sys.stdout, ET.tostring(Root, pretty_print=True)
    else:
        tree = ET.ElementTree(Root)
        tree.write(options.output, pretty_print=True)

    finishedText="\n  Finished index sorting."
    print >> sys.stdout, finishedText
    logging.info(finishedText)

#-------
categories="""
Lu  Letter, Uppercase
Ll  Letter, Lowercase
Lt  Letter, Titlecase
Lm  Letter, Modifier
Lo  Letter, Other
Mn  Mark, Nonspacing
Mc  Mark, Spacing Combining
Me  Mark, Enclosing
Nd  Number, Decimal Digit
Nl  Number, Letter
No  Number, Other
Pc  Punctuation, Connector
Pd  Punctuation, Dash
Ps  Punctuation, Open
Pe  Punctuation, Close
Pi  Punctuation, Initial quote (may behave like Ps or Pe depending on usage)
Pf  Punctuation, Final quote (may behave like Ps or Pe depending on usage)
Po  Punctuation, Other
Sm  Symbol, Math
Sc  Symbol, Currency
Sk  Symbol, Modifier
So  Symbol, Other
Zs  Separator, Space
Zl  Separator, Line
Zp  Separator, Paragraph
Cc  Other, Control
Cf  Other, Format
Cs  Other, Surrogate
Co  Other, Private Use
Cn  Other, Not Assigned (no characters in the file have this property)
"""
# categories=categories.strip()
