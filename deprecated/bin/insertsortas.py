#!/usr/bin/python
# -*- coding: UTF-8 -*-
"""%prog [OPTIONS] DOCBOOKFILES...

   Insert sortas attribut for primary, secondary and tertiary
   indexterms. It does it only, when there is a need for it.

"""

__author__="Thomas Schraitle <tom_schr@web.de>"
__version__="$Id: sortindexterm.py 2611 2007-04-05 15:45:58Z tom $"

from multiplereplace import multiplereplace
from optparse import OptionParser
# from os.path  import basename

import sys
# import logging

try:
    import lxml.etree as ET
except ImportError:
    print >> sys.stderr, \
         "Missing package python-lxml.\n" \
         "Find the packages here:\n" \
         " http://repos.opensuse.org/home:/thomas-schraitle/"
    sys.exit(10000)

# Character maps for mapping "internationalized characters" into ASCII representation
# for better sorting
# TODO: Move this into another file/module

umlautmap_de={
    u"ä": u"ae",
    u"Ä": u"AE",
    u"ü": u"ue",
    u"Ü": u"UE",
    u"ö": u"oe",
    u"Ö": u"OE",
    u"ß": u"ss",
}

umlautmap_fr={
    u"â": u"a^",
    u"á": u"a'",
    u"à": u"a`",
    u"ê": u"e^",
    u"î": u"i^",
    u"ô": u"o^",
    u"é": u"e'",
    u"É": u"E'",
    u"è": u"e`",
    u"È": u"E`",
    u"Ê": u"E^",
}

umlautmap_en=dict(zip(umlautmap_de.keys(), umlautmap_de.values()))


langcode={
    # Collection of language codes:
    'en': umlautmap_en,
    'de': umlautmap_de,
    'fr': umlautmap_fr,
}


def normalize(text):
    """Normalize text, e.g. replaces any number of
    whitespaces with a space character"""
    return " ".join(text.split())


def processChildren(children):
    """Process child elements"""
    text=[]
    for j in children.iterchildren():
        text.append(j.text)
    return ' '.join(text)

class DTDResolver(ET.Resolver):
    """Resolve any DOCTYPE declaration"""
    def resolve(self, url, publicid, context):
        # print "Resolving '%s' '%s'" % (publicid, url)
        # print "Kontext: %s" % (context ) # , dir(context)
        return self.resolve_empty(context)


if __name__=="__main__":
    DB="http://docbook.org/ns/docbook"
    XML="http://www.w3.org/XML/1998/namespace"

    parser = OptionParser(__doc__)
    parser.add_option("-l", "--language",
      dest="lang",
      help="Sort with give language (ISO code)",
    )
    parser.set_defaults(verbose=True)
    parser.add_option("-q", "--quiet",
      action="store_false",
      dest="verbose",
      #default=True,
      help="don't print status messages to stdout"
    )
    parser.add_option("-v", "--verbose",
      action="store_true",
      dest="verbose",
      #default=True,
      help="print status messages to stdout"
    )

    # Parse the command line:
    (options, args) = parser.parse_args()
    if len(args)==0:
        parser.print_help()
        sys.exit(0)

    if options.verbose:
        print "Options: %s\n"\
              "args:    %s" % (options, args)

    for f in args:
        if options.verbose:
            print "Analysing '%s'..." % f
        xmlparser = ET.XMLParser(load_dtd=True, no_network=True)
        xmlparser.resolvers.add( DTDResolver() )
        tree = ET.parse(f, xmlparser)
        root = tree.getroot()
        # Get all indexterms from DocBook, with or without
        # DocBook namespace
        if DB in root.tag:
            indextermpath="//{%s}indexterm" % DB
            langattrib="{%s}lang" % XML
        else:
            indextermpath="//indexterm"
            langattrib="lang"

        #
        if root.get(langattrib)==None and options.lang==None:
            print >> sys.stderr, "ERROR: Expected language code not found.\n"\
            "Description: Language code is neither in your XML file as /*[@lang] or /*[@xml:lang] nor as option with -l/--language.\n"\
            "Solution:    Use the option to insert the language code."
            sys.exit(100)

        # Language in XML has always a higher priority, so check it first:
        if root.get(langattrib):
            lang=root.get(langattrib)
        else:
            lang=options.lang

        # Get language:
        if langcode.get(lang)==None:
            print >> sys.stderr, "ERROR: Language '%s' does not exist.\n"\
            "Description: Could not found a known language.\n"\
            "Solution:    Check your ISO language code." % lang
            sys.exit(200)

        # Build the translate function:
        translate=multiplereplace(langcode.get(lang))

        # Correct umlauts in indexterm/primary and indexterm/secondary
        countidx=0
        for idx in tree.findall(indextermpath):
            countidx+=1
            for i in idx.iterchildren():
                # Don't touch any primarys, secondarys or tertiarys
                # with attribut sortas:
                if i.get('sortas') != None:
                    continue
                #print "*** '%s'" % i.text,
                if i.text == None:
                    #print "none"
                    text = processChildren(i)
                elif i.text.strip()=='':
                    #print "strip"
                    text = processChildren(i)
                else:
                    #print "text=i.text"
                    text = i.text
                text=normalize(text)
                if options.verbose:
                    print "%s = '%s'" % (i.tag, text)
                idxmod = translate(text)
                if text != idxmod:
                    i.attrib["sortas"] = idxmod #translate(i.text)

        if options.verbose:
            print "Handled '%s' indexterm." % countidx

        # Write back the changes
        tree.write("%s-idx.xml" % f.split(".xml")[0])
        del xmlparser, tree
        if options.verbose:
            print "Writing '%s' done." % f
#
# EOF
