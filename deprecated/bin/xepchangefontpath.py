#!/usr/bin/python
# -*- coding: UTF-8 -*-
"""%prog [OPTIONS] XEPCONFIGFILE

   Corrects the contents of xml:base attribute in XEP configuration file 

   Searches for a font given by font-data and changes the path.
   The result is saved in ~/.susedoc/xep-suse.xml
"""

__VERSION__="$Id: xepchangefontpath.py 43057 2009-07-14 06:31:09Z toms $"

import os
import os.path
import sys
import commands

from optparse import OptionParser
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
                    "Please install the package python-lxml.\n"
                sys.exit(10000)
                # Or you might just want to raise an ImportError here.


## Set some constants
# User directory for saving XEP configuration file:
USERDIR=os.path.join(os.path.expanduser( '~' ), ".susedoc/" )
XEPFILE="xep-suse.xml"
PROG=os.path.basename(sys.argv[0])

class FontlistException(Exception):
    pass

class XEPConfigException(Exception):
    pass

class NS:
    """Namespace helper class"""
    def __init__(self, uri):
        """Save the Namespace URI"""
        self.uri = "{%s}" % uri
    def __getattr__(self, tag):
        return self.uri + tag
    def __call__(self, path):
        return "/".join(getattr(self, tag) for tag in path.split("/"))


# Create useful namespaces
XEPNS = NS("http://www.renderx.com/XEP/config" )
XMLNS = NS("http://www.w3.org/XML/1998/namespace")



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
     
#
#
class XEPConfig:
    def __init__(self, filename, verbose=0, output=sys.stdout, hyphenpath=None):
        """Construktor"""
        self.xepconfigname = filename
        self.verbose = verbose
        self.output = output
        self.hyphenpath = hyphenpath
        self.fontlist=None
        if hyphenpath == None:
            if os.environ.has_key("DTDROOT"):
                hyphenpath = os.path.join(os.getenv("DTDROOT"), "etc/XEP/hyphen/")
            else:
                raise ValueError, "I need a path to the hyphenation directory from XEP. " \
                                  "I could not find environment variable DTDROOT. " \
                                  "Use option --hyphen-path"
                
        self.hyphenpath = unicode(hyphenpath)
            
        self.__checkFilenames()
        
    def __checkFilenames(self):
        """Checks if the user's local XEP configuration file exists and renames it if neccessary"""
        if not os.path.exists(self.xepconfigname):
            raise XEPConfigException, "The file '%s' does not exist." % self.xepconfigname
    
        if not os.path.exists(USERDIR):
            os.mkdir(USERDIR)
            if self.verbose:
                print >> sys.stderr, "Created directory '%s'" % USERDIR
        
        if self.output == None:
            filename=os.path.join(USERDIR, XEPFILE)
        else:
            filename=self.output
        
        if os.path.exists(filename):
            if self.verbose:
                print >> sys.stderr, "Info: File '%s' does exist already. Renaming to '%s'" % \
                     (filename, "%s.backup" % filename )
            os.rename(filename, "%s.backup" % filename)
    
    
    def process(self):
        """Generates the XML tree. modifies it and save it back to a different location"""
        #print dir(ET), ET.__file__ 
        #print "ElementTree:", dir(ET.ElementTree)
        doc = ET.parse(self.xepconfigname)
        # docout = ET.ElementTree.Element(XEPNS("config"))
        root = doc.getroot()
        comment = """
 This file is autogenerated by %s. 
 Do NOT EDIT THIS FILE!
 Always regenerate it with the above script.
        """ % PROG

        if hasattr(root, "addprevious"):
          root.addprevious(ET.Comment(comment))
        else:
          root.insert(0, ET.Comment(comment))
    
        fontlist = Fontlist()
    
        for i in doc.getiterator():
            if i.tag == XEPNS("font-group"):
                if i.attrib.has_key(XMLNS("base")):
                    del i.attrib[XMLNS("base")]
            elif i.tag == XEPNS("font-data"):
               
                if i.attrib.has_key("pfb"):
                    keyword = "pfb"
                elif i.attrib.has_key("pfa"):
                    keyword = "pfa"
                elif i.attrib.has_key("pfm"):
                    keyword = "pfm"
                elif i.attrib.has_key("ttf"):
                    keyword = "ttf"
                else:
                    print >> sys.stderr, "WARNING: No attribute pfb, pfa, pfm or ttf found."
                    continue

                try:
                    fontres=fontlist[i.attrib[keyword]]
                    font=i.attrib[keyword]
                except KeyError, e:
                    print >> sys.stderr, e
                    print >> doc.getpath(i)
                    sys.exit(200)
                
                if not len(fontres):
                    if self.verbose:
                        print >> sys.stderr, "WARNING: Could not get font path for fontname '%s'" % font
                    continue
            
                i.attrib[XMLNS("base")] = unicode(fontlist[i.attrib[keyword]][0]+"/")
                if self.verbose > 1:
                    print >> sys.stderr, "* Added font '%s' with xml:base='%s' for '%s'\n  XPath: %s" % \
                                 (fontres[1], fontres[0], font, doc.getpath(i)) 
            

            elif i.tag == XEPNS("languages"):
                # Change the path for hyphen:
                if i.attrib.has_key(XMLNS("base")):
                    i.attrib[XMLNS("base")] = "file://"+self.hyphenpath
        doc.write(self.output)# Write the tree

def main():
    """Initalize the OptionParser"""
    parser = OptionParser(usage=__doc__.split("\n")[0], 
                          version=__VERSION__[5:-2],
                          description="".join(__doc__.split("\n")[1:]).strip())
    parser.set_defaults(output=os.path.join(USERDIR, XEPFILE))
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
    parser.add_option("", "--hyphen-path",
        dest="hyphenpath",
        help="Set path for XEP hyphenation directory, otherwise used $DTDROOT/etc/hyphen")
        
    options, args  = parser.parse_args()
    if len(sys.argv)==1:
        parser.print_help()
        sys.exit(0)
       
    return options, args



if __name__ == "__main__":
    try:
        o, a = main()
        xep=XEPConfig(filename=a[0], 
                      verbose=o.verbose, 
                      output=o.output,
                      hyphenpath=o.hyphenpath)
        xep.process()
        exit(0)

        
    except KeyboardInterrupt:
        print >> sys.stderr, "Aborted by users"
        sys.exit(10000)
    except (ValueError, OSError, XEPConfigException), e:
        print >> sys.stderr, e
        sys.exit(100)
# EOF