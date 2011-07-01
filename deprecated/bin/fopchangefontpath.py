#!/usr/bin/python
# -*- coding: UTF-8 -*-
"""%prog [OPTIONS] FOPCONFIGFILE

Corrects the contents of the <font>s element in FOP configuration file.
It changes the embed-url and metrics-url attributes:

  * embed-url:   Extended metrics file with DTDROOT. If DTDROOT is
                 not set, path from %prog is used.
  * metrics-url: Extended font file with the corresponding font path.
                 This depends on your installed SUSE version

Searches for a font given by font-data and changes the path.
The result is saved in ~/.susedoc/fop-suse.xml
"""

__VERSION__="$Id: fopchangefontpath.py 28151 2008-03-05 09:07:30Z toms $"

import os
import os.path
import sys
import commands
import textwrap

import optparse
from StringIO import StringIO


# from http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/475126
try:
    import xml.etree.ElementTree as ET # in python >=2.5
except ImportError:
    try:
        import cElementTree as ET # effbot's C module
    except ImportError:
        try:
            import elementtree.ElementTree as ET # effbot's pure Python module
        except ImportError:
            try:
                import lxml.etree as ET # ElementTree API using libxml2
            except ImportError:

                print >> sys.stderr, \
                    "Please install the packages python-elementtree, python-lxml or both.\n" \
                    "Find the packages here:\n" \
                    " * python-elementtree:  It's on our distribution\n" \
                    " * python-lxml:         http://repos.opensuse.org/home:/thomas-schraitle/"
                sys.exit(10000)
                # Or you might just want to raise an ImportError here.


## Set some constants
# User directory for saving FOP configuration file:
USERDIR=os.path.join(os.path.expanduser( '~' ), ".susedoc/" )
FOPFILE="fop-suse.xml"

class FontlistException(Exception):
    pass

class FOPConfigException(Exception):
    pass

class NS:
    """Namespace helper class"""
    def __init__(self, uri):
        """Save the Namespace URI"""
        self.uri = uri
    def __getattr__(self, tag):
        return self.uri + tag
    def __call__(self, path):
        return "/".join(getattr(self, tag) for tag in path.split("/"))


# Create useful namespaces
XMLNS = NS("{http://www.w3.org/XML/1998/namespace}")

# Tip from http://www.thescripts.com/forum/thread43301.html
class TextWrapper:
  @staticmethod
  def wrap(text, width=70, **kw):
     result = []
     for line in text.split("\n"):
       result.extend(textwrap.wrap(line, width, **kw))
     return result

  @staticmethod
  def fill(text, width=70, **kw):
     result = []
     for line in text.split("\n"):
       result.append(textwrap.fill(line, width, **kw))
     return "\n".join(result)

  #wrap = staticmethod(wrap)
  #fill = staticmethod(fill)

class Fontlist:
    """Class for font list that is installed in your system"""
    __output=None

    def __init__(self):
        """Construktor"""
        self.__fontlist=[]
        self.__rawoutput=None
        self.__fontdict={}

        self.__fetch()
        self.__process()

    def __fetch(self):
        """Get a list of all fonts from the current system"""
        self.__output=commands.getstatusoutput("fc-list : family file style")
        if self.__output[0] != 0:
            raise FontlistException, "Error from fetching font list: %s" % self.__output[0]
        self.__output=self.__output[1]

    def __process(self):
        """Process the file into a dictionary"""
        for i in self.__output.split("\n"):
            x=i.split(":")
            self.__fontdict[os.path.basename(x[0])]= [ os.path.dirname(x[0]), x[1][1:] ]
            self.__fontlist.append(x[0])

    def __getitem__(self, item):
        """returns Fontlist[item]"""
        return self.__fontdict.get(item, [])

    def __repr__(self):
    #    return str(self)
    #def __str__(self):
        import pprint
        return pprint.pprint(self.__fontdict)

#
#
class FOPConfig:
    def __init__(self, filename, verbose=0, output=sys.stdout):
        """Construktor"""
        self.fopconfigname = filename
        self.verbose = verbose
        self.output = output
        #self.hyphenpath = hyphenpath
        self.fontlist=None
        self.dtdroot = os.environ.get("DTDROOT", \
                        os.path.abspath(os.path.join(os.path.dirname(sys.argv[0]), os.path.pardir)) )

        #if hyphenpath == None:
        #    if os.environ.has_key("DTDROOT"):
        #        hyphenpath = os.path.join(os.getenv("DTDROOT"), "etc/hyphen/")
        #    else:
        #        raise ValueError, "I need a path to the hyphenation directory from FOP. " \
        #                          "I could not find environment variable DTDROOT. " \
        #                          "Use option --hyphen-path"
        #
        # self.hyphenpath = unicode(hyphenpath)


    def __checkFilenames(self):
        """Checks if the user's local FOP configuration file exists and renames it if neccessary"""
        if not os.path.exists(self.fopconfigname):
            raise FOPConfigException, "The file '%s' does not exist." % self.fopconfigname

        if not os.path.exists(USERDIR):
            os.mkdir(USERDIR)
            if self.verbose:
                print >> sys.stderr, "Created directory '%s'" % USERDIR

        if self.output == None:
            filename=os.path.join(USERDIR, FOPFILE)
        else:
            filename=self.output

        if os.path.exists(filename):
            if self.verbose:
                print >> sys.stderr, "Info: File '%s' does exist already.\n" \
                                     "Renaming to '%s'" % \
                     (filename, "%s.backup" % filename )
            os.rename(filename, "%s.backup" % filename)


    def process(self):
        """Generates the XML tree. modifies it and save it back to a different location"""
        #print dir(ET), ET.__file__
        #print "ElementTree:", dir(ET.ElementTree)
        doc = ET.parse(self.fopconfigname)

        fontlist = Fontlist()

        root = doc.getroot()
        if root.tag == "fop" and root.attrib["version"] != "1.0":
           raise FOPConfigException("ERROR: Expected version 1.0 but got %s instead." %
                     root.attrib["version"])

        self.__checkFilenames()

        for i in doc.getiterator():
            if i.tag == "font":
                try:
                    metrics=os.path.basename(i.attrib["metrics-url"])
                    embed_font=os.path.basename(i.attrib["embed-url"])
                    fontres=fontlist[embed_font]
                    if not(fontres):
                      print >> sys.stderr, \
                        "WARNING: The font '%s' does not exist on your system. Skipping." % embed_font
                      continue

                    # print " >>", i.attrib["metrics-url"], embed_font, fontres
                    i.attrib["metrics-url"]= os.path.join("file://",
                                           self.dtdroot,
                                           "etc/FOP",
                                           metrics )

                    i.attrib["embed-url"]= os.path.join("file://",
                                           fontres[0],
                                           embed_font)
                except KeyError, e:
                    print >> sys.stderr, e
                    print >> doc.getpath(i)
                    sys.exit(200)
                except IndexError, e:
                    print >> sys.stderr, e
                    print >> sys.stderr, fontres
                    print >> doc.getpath(i)
                    sys.exit(200)

        doc.write(self.output)# Write the tree

def main():
    """Initalize the OptionParser"""
    optparse.textwrap = TextWrapper()
    parser = optparse.OptionParser(usage=__doc__.split("\n")[0],
                          version=__VERSION__[5:-2],
                          description=__doc__.split("\n\n",1)[1])
    parser.set_defaults(output=os.path.join(USERDIR, FOPFILE))
    parser.add_option("-o", "--output",
        dest="output",
        metavar="FILE",
        help="Save to a given file")
    parser.set_defaults(verbose=0)
    parser.add_option("-v",
        action="count",
        dest="verbose",
        help="Be more descriptive"
        )
#    parser.add_option("", "--hyphen-path",
#        dest="hyphenpath",
#        help="Set path for FOP hyphenation directory, otherwise used $DTDROOT/etc/hyphen")

    options, args  = parser.parse_args()
    if len(sys.argv)==1:
        parser.print_help()
        sys.exit(0)

    return options, args



if __name__ == "__main__":
    try:
        o, a = main()
        fop=FOPConfig(filename=a[0],
                      verbose=o.verbose,
                      output=o.output) # hyphenpath=o.hyphenpath
        fop.process()


    except KeyboardInterrupt:
        print >> sys.stderr, "Aborted by users"
        sys.exit(10000)
    except (ValueError, OSError, FOPConfigException), e:
        print >> sys.stderr, e
        sys.exit(100)
# EOF