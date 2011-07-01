#!/usr/bin/python
# -*- coding: UTF-8 -*-

"""
   Two different methods of detecting the encoding of an XML file.
   Taken from the ASPN site.
"""

import re
import codecs, encodings

def autoDetectXMLEncoding(buffer):
    """ buffer -> encoding_name
    
    The buffer should be at least 4 bytes long.
        Returns None if encoding cannot be detected.
        Note that encoding_name might not have an installed
        decoder (e.g. EBCDIC)
        
    http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/52257
    """
    
    autodetect_dict={ # bytepattern     : ("name",              
                (0x00, 0x00, 0xFE, 0xFF) : ("UCS4_be"),        
                (0xFF, 0xFE, 0x00, 0x00) : ("UCS4_le"),
                (0xFE, 0xFF, None, None) : ("UTF_16_be"), 
                (0xFF, 0xFE, None, None) : ("UTF_16_le"), 
                (0x00, 0x3C, 0x00, 0x3F) : ("UTF_16_be"),
                (0x3C, 0x00, 0x3F, 0x00) : ("UTF_16_le"),
                (0x3C, 0x3F, 0x78, 0x6D): ("UTF_8"),
                (0x4C, 0x6F, 0xA7, 0x94): ("EBCDIC")
                 }
    
    # a more efficient implementation would not decode the whole
    # buffer at once but otherwise we'd have to decode a character at
    # a time looking for the quote character...that's a pain

    encoding = "utf_8" # according to the XML spec, this is the default
                          # this code successively tries to refine the default
                          # whenever it fails to refine, it falls back to 
                          # the last place encoding was set.
    bytes = (byte1, byte2, byte3, byte4) = tuple(map(ord, buffer[0:4]))
    enc_info = autodetect_dict.get(bytes, None)

    if not enc_info: # try autodetection again removing potentially 
                     # variable bytes
        bytes = (byte1, byte2, None, None)
        enc_info = autodetect_dict.get(bytes)

        
    if enc_info:
        encoding = enc_info # we've got a guess... these are
                            #the new defaults

        # try to find a more precise encoding using xml declaration
        secret_decoder_ring = codecs.lookup(encoding)[1]
        (decoded,length) = secret_decoder_ring(buffer) 
        first_line = decoded.split("\n")[0]
        if first_line and first_line.startswith(u"<?xml"):
            encoding_pos = first_line.find(u"encoding")
            if encoding_pos!=-1:
                # look for double quote
                quote_pos=first_line.find('"', encoding_pos) 

                if quote_pos==-1:                 # look for single quote
                    quote_pos=first_line.find("'", encoding_pos) 

                if quote_pos>-1:
                    quote_char,rest=(first_line[quote_pos],
                                                first_line[quote_pos+1:])
                    encoding=rest[:rest.find(quote_char)]

    return encoding


def detectXMLEncoding(fp):
    """ Attempts to detect the character encoding of the xml file
    given by a file object fp. fp must not be a codec wrapped file
    object!

    The return value can be:
        - if detection of the BOM succeeds, the codec name of the
        corresponding unicode charset is returned

        - if BOM detection fails, the xml declaration is searched for
        the encoding attribute and its value returned. the "<"
        character has to be the very first in the file then (it's xml
        standard after all).

        - if BOM and xml declaration fail, None is returned. According
        to xml 1.0 it should be utf_8 then, but it wasn't detected by
        the means offered here. at least one can be pretty sure that a
        character coding including most of ASCII is used :-/
        
     http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/363841
    """
    ### detection using BOM
    
    ## the BOMs we know, by their pattern
    bomDict={ # bytepattern : name              
             (0x00, 0x00, 0xFE, 0xFF) : "UTF_32_be",        
             (0xFF, 0xFE, 0x00, 0x00) : "UTF_32_le",
             (0xFE, 0xFF, None, None) : "UTF_16_be", 
             (0xFF, 0xFE, None, None) : "UTF_16_le", 
             (0xEF, 0xBB, 0xBF, None) : "UTF_8",
            }

    ## go to beginning of file and get the first 4 bytes
    oldFP = fp.tell()
    fp.seek(0)
    (byte1, byte2, byte3, byte4) = tuple(map(ord, fp.read(4)))

    ## try bom detection using 4 bytes, 3 bytes, or 2 bytes
    bomDetection = bomDict.get((byte1, byte2, byte3, byte4))
    if not bomDetection :
        bomDetection = bomDict.get((byte1, byte2, byte3, None))
        if not bomDetection :
            bomDetection = bomDict.get((byte1, byte2, None, None))

    ## if BOM detected, we're done :-)
    if bomDetection :
        fp.seek(oldFP)
        return bomDetection


    ## still here? BOM detection failed.
    ##  now that BOM detection has failed we assume one byte character
    ##  encoding behaving ASCII - of course one could think of nice
    ##  algorithms further investigating on that matter, but I won't for now.
    

    ### search xml declaration for encoding attribute
    import re

    ## assume xml declaration fits into the first 2 KB (*cough*)
    fp.seek(0)
    buffer = fp.read(2048)

    ## set up regular expression
    xmlDeclPattern = r"""
    ^<\?xml             # w/o BOM, xmldecl starts with <?xml at the first byte
    .+?                 # some chars (version info), matched minimal
    encoding=           # encoding attribute begins
    ["']                # attribute start delimiter
    (?P<encstr>         # what's matched in the brackets will be named encstr
     [^"']+              # every character not delimiter (not overly exact!)
    )                   # closes the brackets pair for the named group
    ["']                # attribute end delimiter
    .*?                 # some chars optionally (standalone decl or whitespace)
    \?>                 # xmldecl end
    """

    xmlDeclRE = re.compile(xmlDeclPattern, re.VERBOSE)

    ## search and extract encoding string
    match = xmlDeclRE.search(buffer)
    fp.seek(oldFP)
    if match :
        return match.group("encstr")
    else :
        #return None
        # If the encoding can not be detected, try another function
        return autoDetectXMLEncoding(buffer)


if __name__=="__main__":
   
   import sys
   from os.path import basename
   
   if len(sys.argv) < 2:
       print >> sys.stderr, "Usage: %s XMLFILE" % basename(sys.argv[0])
       sys.exit(0)
   
   for f in sys.argv[1:]:
       print "%s has encoding %s" % (f, detectXMLEncoding(open(f)) )
   
# EOF
