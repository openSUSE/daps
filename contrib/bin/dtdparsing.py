#!/usr/bin/python
"""
Purpose:
 Rudimentary "XML Prolog Parser" to parse XML declaration, DOCTYPE
 declaration, and the internal subset of the DTD.

Description:
 This could be useful as XSLT and some SAX/DOM parsers doesn't retain
 the DOCTYPE declaration and its internal subset.

Caveats:
 The "Name" production from the XML specification is not fully
 implemented. In theory, this could lead to strings which are
 accepted although it would be rejected in the XML spec. As we
 deal currently with ASCII strings in this regard only, this
 is currently negligible.

Requirements:
 pyparsing, http://pyparsing.wikispaces.com

TODO:
 * Implement command line parsing to load a XML file
 * Combine the "loose" ends ;)

See also:
 http://www.w3.org/TR/2008/REC-xml-20081126/#sec-prolog-dtd

(C) 2012 Thomas Schraitle <toms@opensuse.org>
"""

import sys
import os
import re
from pyparsing import Literal, Group, Optional, Suppress, Keyword, \
  alphanums, alphas, Word, ZeroOrMore, CharsNotIn, Regex, \
  QuotedString, removeQuotes, htmlComment, \
  ParseException


xmlstart=Suppress("<?xml")
xmlend=Suppress("?>")
xmlversion=Keyword("version")
xmlencoding=Keyword("encoding")
xmlstandalone=Keyword("standalone")

doctype=Suppress("<!DOCTYPE")

# Define some constants which are suppressed
equal=Suppress("=")
quote=Suppress('"')
apos=Suppress("'")
yesno=Keyword("yes") | Keyword("no")


def EncName():
   """Creates Name
   
    [A-Za-z] ([A-Za-z0-9._] | '-')*
   
    >>> x=EncName()
    >>> x.parseString("Foo")
    (['Foo'], {'EncName': [('Foo', 0)]})
    >>> x.parseString("F01-a")
    (['F01-a'], {'EncName': [('F01-a', 0)]})
   """
   return Word(alphas, alphanums+".-_")("EncName")


def makequoteing(obj):
    '''Makes the right quoting, either 'bla' or "bla"
    
    >>> q=makequoteing("x")
    >>> q.parseString("'x'")
    ([(['x'], {})], {})
    >>> q.parseString("'1'")
    Traceback (most recent call last):
        ...
    ParseException: Expected "x" (at char 1), (line:1, col:2)
    >>> q.parseString("x'")
    Traceback (most recent call last):
        ...
    ParseException: Expected """ (at char 0), (line:1, col:1)
    >>> q.parseString('x"')
    Traceback (most recent call last):
        ...
    ParseException: Expected """ (at char 0), (line:1, col:1)
    
    '''
    return (Group( quote + obj + quote) | \
            Group( apos  + obj + apos))


def EncodingDecl():
   """Parse the encoding string
   EncodingDecl ::= S 'encoding' Eq ('"' EncName '"' | "'" EncName "'" ) 
   
    >>> tests=(
    ... 'encoding="UTF-8"',
    ... "encoding='UTF-8'",
    ... 'encoding="ISO-8869-1"',
    ... 'encoding = "UTF-8" ',
    ... ' encoding =   "UTF-8" ',
    ... ' encoding\\t=\\t"UTF-8" ',
    ... )
    >>> p = EncodingDecl()
    >>> for t in tests:
    ...   result=p.parseString(t)
    ...   print result
    ['encoding', ['UTF-8']]
    ['encoding', ['UTF-8']]
    ['encoding', ['ISO-8869-1']]
    ['encoding', ['UTF-8']]
    ['encoding', ['UTF-8']]
    ['encoding', ['UTF-8']]
   """
   EncodingDecl=xmlencoding + equal + makequoteing(EncName())
   return EncodingDecl.setResultsName("EncodingDecl")

def SDDecl():
   """Parses standalone string
   SDDecl ::= S 'standalone' Eq (("'" ('yes' | 'no') "'") | 
                                 ('"' ('yes' | 'no') '"')) 

    >>> tests=(
    ... 'standalone="yes"',
    ... "standalone='yes'",
    ... 'standalone="no"',
    ... ' standalone = "yes" ',
    ... 'standalone\\t=\\t"yes"\\t',
    ... )
    >>> p = SDDecl()
    >>> for t in tests:
    ...   result=p.parseString(t)
    ...   print result
    ['standalone', ['yes']]
    ['standalone', ['yes']]
    ['standalone', ['no']]
    ['standalone', ['yes']]
    ['standalone', ['yes']]
   """
   SDDecl=xmlstandalone + equal + makequoteing(yesno)
   return SDDecl.setResultsName("SDDecl")
   
def VersionInfo():
   """Parses version string; we allow only 1.0 at the moment
    VersionInfo ::=  S 'version' Eq ("'" VersionNum "'" | '"' VersionNum '"')
    
    >>> # Watch out for correct quoting in doctest:
    >>> tests=( 'version="1.0"',
    ... "version='1.0'",
    ... 'version = "1.0" ',
    ... ' version =   "1.0" ',
    ... ' version\\n=\\n\\t"1.0"\\t',
    ... ' version\\t=\\t"1.0" ',
    ... )
    >>> p = VersionInfo()
    >>> for t in tests:
    ...   result=p.parseString(t)
    ...   print result
    ['version', ['1.0']]
    ['version', ['1.0']]
    ['version', ['1.0']]
    ['version', ['1.0']]
    ['version', ['1.0']]
    ['version', ['1.0']]
   """ 
   version=xmlversion + equal + makequoteing("1.0")
   version.setResultsName("VersionInfo")
   return version


def XMLDecl():
   """Parses a XML declaration
   
    XMLDecl ::= '<?xml' VersionInfo EncodingDecl? SDDecl? S? '?>'
    
    >>> tests=(
    ... '<?xml version="1.0"?>',
    ... "<?xml version='1.0'?>",
    ... '<?xml version="1.0" encoding="UTF-8"?>',
    ... '<?xml version=\\t"1.0"\\tencoding="UTF-8"\\tstandalone\\t="yes"?>',
    ... )
    >>> p = XMLDecl()
    >>> for t in tests:
    ...   result=p.parseString(t)
    ...   print result
    ['version', ['1.0']]
    ['version', ['1.0']]
    ['version', ['1.0'], 'encoding', ['UTF-8']]
    ['version', ['1.0'], 'encoding', ['UTF-8'], 'standalone', ['yes']]
   """
   XMLDecl= xmlstart + VersionInfo() + \
         Optional(EncodingDecl()) + \
         Optional(SDDecl()) + \
         xmlend
   return XMLDecl.setResultsName("XMLDecl")


def PubidChar(excludeApos=False):
   """Parses public identifier characters
   
   PubidChar ::= #x20 | #xD | #xA | [a-zA-Z0-9] | [-'()+,./:=?;!*#@$_%]
   
    >>> tests=(
    ... 'OASIS',
    ... '-//W3C//DTD SVG 1.0//EN',
    ... '-//W3C//ELEMENTS SVG 1.1',
    ... '-//OASIS//DTD DocBook XML V4.2//EN',
    ... '-//OASIS//ENTITIES DocBook Notations V4.2//EN',
    ... )
    >>> p = PubidChar()
    >>> for t in tests:
    ...   result=p.parseString(t)
    ...   print result
    ['OASIS']
    ['-//W3C//DTD SVG 1.0//EN']
    ['-//W3C//ELEMENTS SVG 1.1']
    ['-//OASIS//DTD DocBook XML V4.2//EN']
    ['-//OASIS//ENTITIES DocBook Notations V4.2//EN']
   """
   chars=' \u0d\u0a' + alphanums + "-()+,./:=?;!*#@$_%"
   if not excludeApos:
       chars += "'"
   return Word(chars)("PubidChar")


def PubidLiteral():
   """Parses public identifier characters with quotes (single or double)
   
   PubidLiteral ::= '"' PubidChar* '"' | "'" (PubidChar - "'")* "'"
    
    >>> tests=(
    ... "'OASIS'",
    ... "'-//OASIS//DTD DocBook XML V4.2//EN'",
    ... '"-//OASIS//DTD DocBook XML V4.5//EN"',
    ... "'-//W3C//DTD SVG 1.0//EN'",
    ... "'-//W3C//ELEMENTS SVG 1.1'",
    ... "'-//OASIS//ENTITIES DocBook Notations V4.2//EN'",
    ... )
    >>> p = PubidLiteral()
    >>> for t in tests:
    ...   result=p.parseString(t)
    ...   print result
    ['OASIS']
    ['-//OASIS//DTD DocBook XML V4.2//EN']
    ['-//OASIS//DTD DocBook XML V4.5//EN']
    ['-//W3C//DTD SVG 1.0//EN']
    ['-//W3C//ELEMENTS SVG 1.1']
    ['-//OASIS//ENTITIES DocBook Notations V4.2//EN']
   """
   # ("Group1")
   P1=quote + ZeroOrMore(PubidChar()) + quote 
   # ("Group2")
   P2=apos + ZeroOrMore(PubidChar(excludeApos=True)) + apos
   return (P1 | P2)('PubidLiteral')


def SystemLiteral():
   """Parses system identifier characters with quotes (single or double)
   
   SystemLiteral ::=   ('"' [^"]* '"') | ("'" [^']* "'") 
   
    >>> tests=(
    ... "'foo.xml'",
    ... '"foo.xml"',
    ... "'http://www.example.org/foo'",
    ... "'http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd'",
    ... )
    >>> p = SystemLiteral()
    >>> for t in tests:
    ...   result=p.parseString(t)
    ...   print result
    ['foo.xml']
    ['foo.xml']
    ['http://www.example.org/foo']
    ['http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd']
   """
   # P1=QuotedString('"').setParseAction(removeQuotes)
   P1= quote + ZeroOrMore(CharsNotIn('"'))('SystemLiteral') + quote
   # P2=QuotedString("'").setParseAction(removeQuotes)
   P2= apos + ZeroOrMore(CharsNotIn("'"))('SystemLiteral') + apos
   return (P1 | P2) # ('SystemLiteral')

   
def ExternalID():
   """Parses either SYSTEM or PUBLIC identifiers
   
   ExternalID ::=  'SYSTEM' S SystemLiteral
                 | 'PUBLIC' S PubidLiteral S SystemLiteral
    
    >>> tests=(
    ... "SYSTEM 'foo'",
    ... 'SYSTEM "foo"  ',
    ... "SYSTEM ''",
    ... "SYSTEM 'http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd'",
    ... "PUBLIC '-//OASIS//DTD DocBook XML V4.5//EN' 'http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd'",
    ... )
    >>> p = ExternalID()
    >>> for t in tests:
    ...   result=p.parseString(t)
    ...   print result
    ['foo']
    ['foo']
    []
    ['http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd']
    ['-//OASIS//DTD DocBook XML V4.5//EN', 'http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd']
   """
   P1 = Suppress('SYSTEM') + SystemLiteral()
   P2 = Suppress('PUBLIC') + PubidLiteral() + SystemLiteral()
   return (P1 | P2)('ExternalID')


def DoctypeDecl():
   """Parses a DOCTYPE declaration
   
    doctypedecl ::= '<!DOCTYPE' S Name (S ExternalID)? S? ('[' intSubset ']' S?)? '>'
   
    >>> testsSystem = (
    ... '''<!DOCTYPE foo SYSTEM "foo.dtd">''',
    ... '''<!DOCTYPE foo SYSTEM "foo.dtd" []>''',
    ... '''<!DOCTYPE foo SYSTEM "foo.dtd" [ ] >''',
    ... '''<!DOCTYPE foo SYSTEM "foo.dtd" [ <!-- foo --> ] >''',
    ... '''<!DOCTYPE foo SYSTEM "foo.dtd" [
    ...    <!-- bar -->
    ...    ]
    ... >'''
    ... )
    >>> p = DoctypeDecl()
    >>> for t in testsSystem:
    ...   result=p.parseString(t)
    ...   print result
    ['foo', 'foo.dtd']
    ['foo', 'foo.dtd', '[]']
    ['foo', 'foo.dtd', '[ ]']
    ['foo', 'foo.dtd', '[ <!-- foo --> ]']
    ['foo', 'foo.dtd', '[\\n   <!-- bar -->\\n   ]']
    >>>
    >>> testsPublic = (
    ... '''<!DOCTYPE foo PUBLIC
    ...     "urn:foo:dtd"
    ...     "foo.dtd" 
    ...  [
    ...   <!-- baz -->
    ...  ] >''',
    ... '''<!DOCTYPE foo PUBLIC
    ...   "-//TMS/DTD DocBook XML V4.2//EN"
    ...   "http://www.example.org/tms/docbook.dtd"
    ... [
    ...  <!-- Hallo -->
    ... ]>''',
    ... )
    >>> for t in testsPublic:
    ...   result=p.parseString(t)
    ...   print result
    ['foo', 'urn:foo:dtd', 'foo.dtd', '[\\n  <!-- baz -->\\n ]']
    ['foo', '-//TMS/DTD DocBook XML V4.2//EN', 'http://www.example.org/tms/docbook.dtd', '[\\n <!-- Hallo -->\\n]']
   """
   # Suppress('[') + \ # Suppress(']')
   d = Suppress('<!DOCTYPE') + \
       Word(alphas, alphanums)('root') + \
       Optional(ExternalID()) + \
       Optional(Regex("\[(.*)\]", re.MULTILINE|re.DOTALL)("intsubset") ) + \
       Suppress('>')
   return d


def PIs():
   """Parses Processing Instructions
   
    PI ::= '<?' PITarget (S (Char* - (Char* '?>' Char*)))? '?>'
    
    >>> tests=(
    ...  '''<?foo?>''',
    ...  '''<?foo ?>''',
    ...  '''<?foo abc def ghi ?>''',
    ...  '''<?xml-stylesheet foo="bla" bar="x" ?>''',
    ...  '''<?xml-stylesheet
    ...    foo="bla"
    ...    foo="x"
    ...  ?>''',
    ... )
    >>> p=PIs()
    >>> for t in tests:
    ...   result=p.parseString(t)
    ...   print result
    ['foo']
    ['foo', ' ']
    ['foo', ' abc def ghi ']
    ['xml-stylesheet', ' foo="bla" bar="x" ']
    ['xml-stylesheet', '\\n   foo="bla"\\n   foo="x"\\n ']
   """
   pi=Suppress('<?') + \
        Word(alphas, alphanums+'-_')('pitarget') + \
        ZeroOrMore(CharsNotIn('?>'))('picontents') + \
        Suppress('?>')
   return pi
   

def Misc():
   """Parses PIs and comments
   
    Misc ::=  Comment | PI | S 
   
    >>> tests=(
    ... '''<?foo?>''',
    ... '''<!-- Comment -->''',
    ... )
    >>> p = Misc()
    >>> for t in tests:
    ...   result=p.parseString(t)
    ...   print result
    ['foo']
    ['<!-- Comment -->']
   """
   return ( htmlComment('comment') | PIs() )

   
def Prolog():
   """Parses prolog of a XML string
   
    prolog ::=  XMLDecl? Misc* (doctypedecl Misc*)?

    >>> tests=(
    ...  '''<?xml version="1.0"?>
    ... <!DOCTYPE foo []>
    ... <!-- Foo Comment -->
    ... ''',
    ...  '''<!DOCTYPE bar SYSTEM "bar.dtd" [ <!-- Hallo --> ] >
    ... <!-- Bla Comment -->
    ... ''',
    ... )
    >>> p=Prolog()
    >>> for t in tests:
    ...   result=p.parseString(t)
    ...   print result
    ['version', ['1.0'], 'foo', '[]', '<!-- Foo Comment -->']
    ['bar', 'bar.dtd', '[ <!-- Hallo --> ]', '<!-- Bla Comment -->']
   """
   misc=ZeroOrMore( Misc() )
   p = Optional(XMLDecl()) + \
       misc + \
       Optional(DoctypeDecl() + \
                misc
               )
   return p
   
    
if __name__ == "__main__":
    import doctest
    doctest.testmod()

# EOF