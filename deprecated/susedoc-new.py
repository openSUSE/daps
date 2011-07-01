#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
This script creates a sandbox to work with a XML environment. 
See README for more information.
"""

import os
import os.path
import sys
from optparse import OptionParser, OptionValueError

__version__="$Id: susedoc-new.py 32324 2008-06-18 07:29:38Z toms $"
__author__="Thomas Schraitle <thomas DOT schraitle (AT) suse DOT de>"
__license__="GPL v2.0"

# Where are our stylesheets?
RPMROOTDIR="/usr/share/susedoc"

# Which DTDs are allowed?
DTDS=("novdoc",
      "docbook_41",
      "docbook_42",
      "docbook_43",
      "docbook_44",
      "docbook_45",
     )

# Which root elements are allowed?
ROOT_ELEMENTS=("article",
               "book",
               #"set", # Needs to be implemented
              )

# Which formatter are supported?
XSLFO_FORMATTER=("xep", "fop")

# The path for the DocBook XSL stylesheets. 
# Maybe find a more portable solution across different Linux
# distribution (xmlcatalog?) On (open)SUSE it's: 
DBXSLPATH="/usr/share/xml/docbook/stylesheet/nwalsh/current/"


class Novdoc:
    """This class represents the Novdoc DTD"""
    allowed_versions=("1.0")

    def __init__(self, version="1.0"):
        self.setVersion(version)

    def __repr__(self):
        return "<class Novdoc(%s): '%s' '%s'>" % (
                self.version(),
                self.publicid(),
                self.systemid())

    def setVersion(self, version):
        if version not in self.allowed_versions:
            raise ValueError("ERROR: Not valid version number for Novdoc. "\
                             "Got '%s'" % version)
        self.__version=version
        self.__publicid="-//Novell//DTD NovDoc XML V%s//EN" % version
        self.__systemid="novdocx.dtd"

    def version(self):
        return self.__version
    def identifier(self):
        return (self.publicid(), self.systemid())
    def publicid(self):
        return self.__publicid
    def systemid(self):
        return self.__systemid


class DocBook:
    """This class represents the DocBook DTD"""
    # We are interested in the 4.x series:
    allowed_versions=("4.1", "4.2", "4.3", "4.4",
                       "4.5", # Allow latest version
                     )

    def __init__(self, version="4.4"):
        self.setVersion(version)

    def __repr__(self):
        return "<class DocBook(%s): '%s' '%s'>" % (
                  self.version(),
                  self.publicid(),
                  self.systemid() )

    def setVersion(self, version):
        if version not in self.allowed_versions:
            raise ValueError("ERROR: Not valid version number for DocBook. "\
                             "Got '%s'" % version)
        self.__version=version
        self.__publicid="-//OASIS//DTD DocBook XML V%s//EN" % version
        self.__systemid="http://www.docbook.org/xml/%s/docbookx.dtd" % version

    def version(self):
        return self.__version
    def identifier(self):
        return (self.publicid(), self.systemid())
    def publicid(self):
        return self.__publicid
    def systemid(self):
        return self.__systemid


class DocBuildException(Exception):
    """Exception for DocBuild"""
    pass


class DocBuild:
    def __init__(self, args):
        self.args = args

        if self.args.dtdname != None and self.args.dtdname.lower() not in DTDS:
            raise DocBuildException("ERROR: Supported DTDs are Novdoc and DocBook. "\
                                    "Got '%s'" % dtdname)
        if self.args.root not in ROOT_ELEMENTS:
            raise DocBuildException("ERROR: Supported root elements are article, book and set. "
                        "Got '%s'" % root)



    def __repr__(self):
        return "<class DocBuild 0x%x>" % id(self)

    def __createDirs(self):
        """Creates all necessary directories"""
        os.mkdir(self.args.docroot)
        docroot=self.args.docroot
        djoin=os.path.join
        # Create directory structure
        for d in (djoin(docroot, "xml"),
                  djoin(docroot, "images"),
                  #djoin(docroot, "tmp"), # Created by Makefile
                  djoin(docroot, "images/gen"),
                  djoin(docroot, "images/src"),
                  djoin(docroot, "images/src/png"),
                  djoin(docroot, "images/src/svg"),
                  djoin(docroot, "images/src/fig"),
                  djoin(docroot, "images/src/dia"),
                  ):
            os.mkdir(d)
            if self.args.verbose:
                print "Created directory '%s'" % d

    def __createENVfile(self):
        docroot=self.args.docroot
        bookname = self.args.bookname
        f="/".join([docroot,"ENV-%s" % bookname])
        env = open(f, "w")
        vals={
          "dtdroot":  RPMROOTDIR,
          "bookname": bookname,
        }

        print >> env,  """# -*- shell-script -*-
# This is the ENV file to set all necessary environment variables
# Run it for the first time with:
#  source ENV-%(bookname)s

. .env-profile

export MAIN="MAIN.%(bookname)s.xml"
export BOOK="%(bookname)s"

## If you want a chapter, appendix, insert the id:
#export ROOTID=

## Profiling stuff:
#export PROFOS=""
#export PROFARCH=""

export DISTVER=10.2
""" % vals

        # XSLFO_FORMATTER
        env.close()
        if self.args.verbose:
                print "Created ENV file  '%s'" % (f)
        f="/".join([docroot,".env-profile"])
        env = open(f, "w")
        print >> env, """# -*- shell-script -*-
unset DTDROOT
export DTDROOT=$(make dtdroot)
echo "Using the DTDROOT ${DTDROOT}"
. $DTDROOT/etc/system-profile

mkdir -p xml profiled tmp images/{print,online} \
        images/src/{fig,png,svg,dia} \
        images/gen/{png,svg}
"""
        env.close()
        if self.args.verbose:
                print "Created file      '%s'" % (f)


    def __createMakefile(self):
        docroot=self.args.docroot
        f="/".join([docroot,"Makefile"])
        make = open(f, "w")
        print >> make, """# .PHONY: default
# default: help

ifndef DTDROOT
DTDPATH1 = /usr/share/susedoc
DTDPATH2 = $(shell test -d ../../novdoc && (cd ../../novdoc; pwd))
DTDPATH3 = $(shell test -d ../../../../trunk/novdoc && (cd ../../../../trunk/novdoc; pwd))

# Change the order to find the correct susedoc path:
DTDROOT := $(firstword $(DTDPATH2) $(DTDPATH3) $(DTDPATH1))
else
include $(DTDROOT)/make/common.mk
endif

.PHONY: dtdroot
dtdroot:
	@echo $(DTDROOT)

# Emacs:
# Local Variables:
# End:""" % { "root": RPMROOTDIR }
        make.close()
        if self.args.verbose:
                print "Created Makefile  '%s'" % (f)

    def fileHeader(self):
        return '<?xml-stylesheet ' \
               'href="urn:x-suse:xslt:profiling:%s-profile.xsl" ' \
               'type="text/xsl" ?>\n' % self.args.dtdname.replace("_", "")

    def fileFooter(self):
        return """<!-- Keep this comment at the end of the file
Local variables:
mode: xml
sgml-indent-step:3
sgml-omittag:nil
sgml-shorttag:nil
End:
-->"""

    def createAuthor(self):
        return """      <author>
         <firstname>Tux</firstname>
         <surname>Penguin</surname>
      </author>"""

    def createTitle(self, booktype):
        return """<title>The DocBuild Demonstration %s</title>""" % booktype

    def __createEntityFile(self, entityname="entity-decl.ent"):
        docroot=self.args.docroot
        bookname=self.args.bookname
        root=self.args.root
        dtdname=self.args.dtdname
        f="/".join([docroot,"xml/%s" % entityname])
        ent=open(f, "w")
        print >> ent, """<!-- %(entityname)s -->
<!ENTITY suse     "SUSE">
<!ENTITY opensuse "openSUSE">
""" % { "entityname": entityname }
        ent.close()
        if self.args.verbose:
                print "Created Ent.File  '%s'" % (f)

    def __createMAIN(self):
        docroot=self.args.docroot
        bookname=self.args.bookname
        root=self.args.root
        dtdname=self.args.dtdname
        f="/".join([docroot,"xml/MAIN.%s.xml" % bookname])

        if dtdname.startswith("novdoc"):
            dtd=Novdoc()
        elif dtdname.startswith("docbook"):
            ver=dtdname.split("_")[1]
            # print "*** DocBook Version:",
            dtd=DocBook( ".".join(list(ver)) )
        else:
            raise ValueError("ERROR: Expected one of %s" % ", ".join(DTDS) )

        if self.args.lang != None:
            lang = ' lang="%s"' % self.args.lang
        else:
            lang='' #  lang="en"

        pub, sys = dtd.identifier()

        if root == "article":
            content= """   <articleinfo>
%s
      %s
   </articleinfo>
   <sect1 id="sec.overview">
      <title>Overview</title>
      <para>Your Text</para>
   </sect1>""" % (self.createAuthor(), self.createTitle("Article") )

            if self.args.xinclude:
                content += """
   <xi:include xmlns:xi="http://www.w3.org/2001/XInclude"
            href="foo.xml"/>"""

        elif root == "book":
          if dtdname.startswith("novdoc"):
            content= """   <bookinfo>
      %s
      <productname></productname>
      <date></date>
      <!-- <titleabbrev></titleabbrev> -->
      <legalnotice>
          <para>All about license issues.</para>
      </legalnotice>
   </bookinfo>""" % self.createTitle("Book")
          else:
            content= """   <bookinfo>
      %s
%s
   </bookinfo>""" % (
     self.createTitle("Book"), self.createAuthor()
   )
          # Insert chapters:
          content += """
   <chapter id="chap.overview">
      <title>Overview</title>
      <para>This paragraph is describing an overview.</para>
   </chapter>"""
          if self.args.xinclude:
             content += """
   <xi:include xmlns:xi="http://www.w3.org/2001/XInclude"
            href="foo.xml"/>"""

        elif root == "set":
            content="<!-- set -->" #FIXME

        else:
            raise ValueError("ERROR: Expected article, book or set but got '%s'" % root)


        xml=open(f, "w")
        print >> xml, """<?xml version="1.0" encoding="UTF-8"?>"""
        print >> xml, self.fileHeader()
        print >> xml, """<!DOCTYPE %(root)s PUBLIC
  "%(pub)s"
  "%(sys)s"
[
  <!-- Reference to an external entity file here. For example:

  <!ENTITY entity.ent SYSTEM "entity-decl.ent">
  %%entity.ent;
  -->
]>

<%(root)s%(lang)s>
%(content)s
</%(root)s>

%(footer)s
""" %   {
          "root":    root,
          "pub":     pub,
          "sys":     sys,
          "lang":    lang,
          "content": content,
          "footer":  self.fileFooter()
        }
        #print >> xml, """</%s>\n%s""" % (root, self.fileFooter() )
        xml.close()
        if self.args.verbose:
                print "Created MAIN      '%s'" % (f)

    def __createFoo(self):
        if self.args.xinclude in (None, False):
            return
        docroot=self.args.docroot
        bookname=self.args.bookname
        root=self.args.root
        x={"article": "sect1", "book": "chapter", "set": "book"}
        root=x[root]
        dtdname=self.args.dtdname
        f="/".join([docroot,"xml/foo.xml"])
        if dtdname.startswith("novdoc"):
            dtd=Novdoc()
        elif dtdname.startswith("docbook"):
            ver=dtdname.split("_")[1]
            # print "*** DocBook Version:",
            dtd=DocBook( ".".join(list(ver)) )
        else:
            raise ValueError("ERROR: Expected one of %s" % ", ".join(DTDS) )

        pub, sys = dtd.identifier()
        foo=open(f, "w")
        print >> foo, """<?xml version="1.0" encoding="UTF-8"?>"""
        print >> foo, """<!DOCTYPE %(root)s PUBLIC
  "%(pub)s"
  "%(sys)s"
[
  <!-- Reference to an external entity file here. For example:

  <!ENTITY entity.mod SYSTEM "entity.mod">
  %%entity.mod;
  -->
]>""" % {
          "root":    root,
          "pub":     pub,
          "sys":     sys,
          "footer":  self.fileFooter()
        }

        if root=="sect1":
            print >> foo, """
<sect1 id="sec.foo">
   <title>Section Foo</title>
   <para>This is the paragraph of a section that is included by xi:include.</para>
</sect1>
"""
        elif root=="chapter":
            print >> foo, """
<chapter id="cha.foo">
  <title>Chapter Foo</title>
  <para>This is the paragraph of a chapter that is included by xi:include.</para>
  <para>And here is the second paragraph.</para>
</chapter>
"""
        elif root=="book":
            print >> foo, """<!-- For set (UNIMPLEMENTED) -->\n"""
        else:
            print >> foo, "<!-- ??? -->\n"

        print >> foo, self.fileFooter()
        foo.close()
        if self.args.verbose:
                print "Created foo.xml   '%s'" % (f)

    def __createREADME(self):
        docroot=self.args.docroot
        f="/".join([docroot,"README"])
        readme = open(f, "w")
        print >> readme, """--- README ---

   SUSE XML Build System (susedoc)

What you see here is the susedoc XML build environment to create books 
in XML with the DocBook or Novdoc DTD. We (the SUSE documentation team)
created this script to simplify the task of creating new documents.

-------------------------------------------------------------
1. Building Books
-------------------------------------------------------------
To initialize your current shell, enter for the first time (The dollar
sign '$' means the commandline prompt):

   $ source ENV-%(bookname)s

To build your book as PDF, use:

   $ make pdf

   or use the default target:

   $ make

To build your book as HTML, use:

   $ make html

To see an overview of all available targets, enter:

   $ make help

Detailed documentation can be found at %(docdir)s.
Discuss documentation on our mailinglist <opensuse-doc@opensuse.org>.

* Subscribe:  <opensuse-doc+subscribe@opensuse.org>
  http://en.opensuse.org/Communicate#Mailing_Lists
* Archive:    http://lists.opensuse.org/opensuse-doc/
* Docu Team:  http://en.opensuse.org/Documentation_Team

-------------------------------------------------------------
2. Structure
-------------------------------------------------------------
 + xml       All your XML files are stored here
 + tmp       Temporary directory
 + images    Contains the image directories
   +- src    Source directory where all your original
   |  |      images reside
   |  +-png  Save your PNG images here
   |  +-svg  Save your SVG images here
   |  +-fig  Save your FIG images here
   |
   +- print  Do not save any images.
   |         Grayscale images will be saved
   +- online Do not save any images



-------------------------------------------------------------
3. Files
-------------------------------------------------------------
 + README    You are reading this file
 + ENV-%(bookname)s
             Before you start
 + xml/MAIN.%(bookname)s.xml
             This is the starting point of your document.
             In general it is splitted into several other
             files. For example, a book can have different
             chapters, each in a separate file.
 + xml/entity-decl.ent
             This is an optional file that contains entity
             declarations. Entities are a kind of a placeholder.
             To use it you have to uncomment the line beginning
             with "<!ENTITY" in your MAIN.%(bookname)s.xml
        """ % {
                "bookname": self.args.bookname,
                "docdir":   os.path.join(RPMROOTDIR, "doc"),
              }
        readme.close()
        if self.args.verbose:
                print "Created README    '%s'" % (f)

    def docbuildusage(self):
        print >> sys.stdout, """%(line)s
  Summary
%(line)s

To work with the XML build system, do the following
($ means the prompt):

 1. Change the directory to '%(dir)s':
    $ cd %(dir)s

 2. Source the ENV-%(bookname)s (needed only once):
    $ source ENV-%(bookname)s

 3. Run make to get an overview of possible targets:
    $ make help

 4. Create HTML with:
    $ make html

 5. Create PDF with cropmarks:
    $ make pdf

 6. Create PDF without cropmarks:
    $ make color-pdf

Remember to have fun! :-)

*** Your working directory is '%(dir)s'. ***
""" % {
        "line": 20*"-",
        "dir": self.args.docroot,
        "bookname": self.args.bookname,
      }

    def printOptions(self):
        vals = {
            "docroot":  self.args.docroot,
            "bookname": self.args.bookname,
            "lang":     self.args.lang,
            "dtd":      self.args.dtdname,
            "root":     self.args.root,
            "xinclude": self.args.xinclude,
            "xslfoformatter": self.args.xslfoformatter,
           }

        print >> sys.stdout, """
This script has used the following options:

  Installation directory:  '%(docroot)s'
  Book name:               '%(bookname)s'
  Language:                %(lang)s
  Used XML DTD:            '%(dtd)s'
  Root Element:            '%(root)s'
  XInclude:                %(xinclude)s
  XSL-FO Formatter:        %(xslfoformatter)s
     """ % vals

    def install(self):
        # Create the structure
        self.__createDirs()
        # Create ENV file
        self.__createENVfile()
        # Create Makefile
        self.__createMakefile()
        # Create MAIN
        self.__createMAIN()
        # Create Entity File
        self.__createEntityFile()
        # Create foo.xml file, if necessary:
        self.__createFoo()
        # Create README
        self.__createREADME()
        print >> sys.stdout, "*** Build directory succesfully created. ***"
        # Print a summary of the options:
        self.printOptions() #FIXME
        # Print a help text what to do next:
        self.docbuildusage()


def cb_check_bookname(option, opt, value, parser):
    """Callback function to check for valid booknames"""
    notallowedchars = set((" ", "%", "!", "/", "&", "\"",
                           "\\", "'", "#", "?", "*", "$", "~" ))

    # FIXME: Find a better method?
    if len(set(value) & notallowedchars):
        raise OptionValueError("bookname contains inappropriate characters.")
    else:
        setattr(parser.values, option.dest, value)


def main():
    parser = OptionParser(usage="%prog [options]",
                         version="%prog " + __version__[3:-1],
                         description="""%prog is used to create a working XML environment
for DocBook/Novdoc documents.
                         """ #% {"lic": __license__}
                         )
    parser.set_default("verbose", True)
    parser.add_option("-v", "--verbose",
                     action="store_true",
                     help="Show what's happening (default: %default)")
    parser.set_default("license", False)
    parser.add_option("","--license",
                     action="store_true",
                     help="Show license information"
                     )
    parser.add_option("-q", "--quiet",
                     action="store_false",
                     dest="verbose",
                     help="Don't print messages")
    parser.set_default("bookname", "hello_world")
    parser.add_option("-b", "--bookname",
                     action="callback",
                     nargs=1, type="string",
                     callback=cb_check_bookname,
                     dest="bookname",
                     help="Name of your book without spaces (default: %default)" )
    parser.add_option("-l", "--language",
                     dest="lang",
                     help="Set the language of your document, like 'en' for English, " \
                          "'de' for German, ... (ISO 639)" )
    parser.set_default("docroot", "./susedoc-xmltest")
    parser.add_option("-D", "--docroot",
                     dest="docroot",
                     help="Complete non-existing path for all the directories and files (default: %default)")
    parser.add_option("-d", "--dtdname",
                     dest="dtdname",
                     choices=DTDS,
                     help="Which XML DTD to use: %s" % ", ".join(DTDS) )
    parser.set_default("root", "book")
    parser.add_option("-r", "--root",
                     dest="root",
                     choices=ROOT_ELEMENTS,
                     help="Root element (default: %default). "\
                          "Available elements are: " + ", ".join(ROOT_ELEMENTS)
                     )
    parser.set_default("xslfoformatter", "fop")
    parser.add_option("-f", "--xslfo-formatter",
                     dest="xslfoformatter",
                     choices=XSLFO_FORMATTER,
                     help="Choose a XSL-FO formatter (default: %default). "\
                          "Available formatters are: " + ", ".join(XSLFO_FORMATTER)
                     )
    parser.set_default("xinclude", True)
    parser.add_option("", "--with-xinclude",
                     dest="xinclude",
                     action="store_true",
                     help="Generate Main with XInclude elements and dedicated files" )
    parser.add_option("", "--without-xinclude",
                     dest="xinclude",
                     action="store_false",
                     help="Generate Main without XInclude elements" )

    (options, args) = parser.parse_args()

    # print options

    if options.license:
      print >> sys.stdout, \
            "*** License ***\n\nThis Python script is licencend under the GPL v2.0\n"\
            "See http://www.fsf.org/licensing/licenses/gpl.html for the full text.\n"
      sys.exit(0)

    if options.dtdname == None:
      parser.print_help()
      parser.error("Choose a DTD with -d or --dtdname")


    # print options, args
    return options, args


if __name__=="__main__":
    try:
        options, args = main()
        doc = DocBuild(options)
        doc.install()
    except (ValueError, OSError), e:
        print >> sys.stderr, e
        print >> sys.stderr, "Please remove your unfinished directory manually, if necessary."
