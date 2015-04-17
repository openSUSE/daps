#!/usr/bin/python3

__version__ = "0.1"
__author__="Thomas Schraitle <toms AT opensuse DOT org>"
__license__="GPL 2 or GPL 3"
__doc__="""Creates a list of dependent files
"""

import re
import sys
import logging

try:
    from lxml import etree
except ImportError as err:
    print("""{}
Solution: Install the package python3-lxml.""".format(err),
          file=sys.stderr)
    sys.exit(10)

log = logging.getLogger(__file__)
ch = logging.StreamHandler(sys.stderr)
frmt = logging.Formatter('%(levelname)s: %(message)s')
ch.setFormatter(frmt)
log.setLevel(logging.DEBUG)
log.addHandler(ch)

# Our default mappings of namespace prefixes to namespaces
nsmap={ 'd': 'http://docbook.org/ns/docbook',
       'xl': 'http://www.w3.org/1999/xlink',
       'xi': 'http://www.w3.org/2001/XInclude',
      }

def defaultxmlparser(**kwargs):
    """Return a default parser
    (encoding='UTF-8', resolve_entities=True, load_dtd=True)

    :param kwargs: dictionary of values for `etree.XMLParser`
    :return: instance of `etree.XMLParser` objecst
    """

    # Set default values, otherwise entity resolution doesn't work:
    kwargs.setdefault('encoding', "UTF-8")
    kwargs.setdefault('resolve_entities', True)
    kwargs.setdefault('load_dtd', True)

    #encoding="UTF-8",
    #attribute_defaults=attribute_defaults,
    #dtd_validation=dtd_validation,
    #load_dtd=load_dtd,
    #no_network=no_network,
    #ns_clean=ns_clean,
    #recover=recover,
    #remove_blank_text=remove_blank_text,
    #resolve_entities=resolve_entities,
    #remove_comments=remove_comments,
    #remove_pis=remove_pis,
    #strip_cdata=strip_cdata,
    #target=target,
    #compact=compact
    return etree.XMLParser(**kwargs)

def cliparse():
    """Return result of ArgumentParser"""
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)

    parser.add_argument('-v', '--verbose',
        action='count',
        help="Increase verbosity level"
        )
    parser.add_argument("--admon-path", "-A",
        default='',
        metavar="PATH",
        help="Path to admonitions graphics",
        )
    parser.add_argument("--admon-ext", # "",
        default='.png',
        metavar="EXT",
        help="Extension for admonition graphics (default %(default)s)",
        )
    parser.add_argument("--callout-path", "-C",
        default='',
        metavar="PATH",
        help="Path to callout graphics",
        )
    parser.add_argument("--callout-ext", # "",
        default='.png',
        metavar="EXT",
        help="Extension for callout graphics (default %(default)s)",
        )
    parser.add_argument("--img-src-path", "-I",
        default='',
        metavar="PATH",
        help="Path to ordinary graphics",
        )

    parser.add_argument("--preferred-mediaobject-role", "-R",
        default='html',
        metavar="ROLE",
        help="Select which mediaobject to use based on this value of an object's role attribute  (default %(default)s)",
        )
    #parser.add_argument("-p", "--param",
        ## nargs='*',
        #action="append",
        #help="key/value pair as KEY=VALUE")
    parser.add_argument("files",
        nargs='+',
        help="XML file(s)")

    args=parser.parse_args()
    loglevel = {None: logging.NOTSET,
                #1:logging.CRITICAL,
                #2:logging.ERROR,
                #1:logging.WARNING,
                1:logging.INFO,
                2:logging.DEBUG,
               }
    log.setLevel(loglevel.get(args.verbose, logging.DEBUG))
    return args

#
def localname(element):
    """Returns the local name part of an lxml element node or string
       The element name is taken from the `.tag` property
       Works with or without a namespace

    >>> localname('{http://docbook.org/ns/docbook}imageobject')
    'imageobject'
    >>> localname('foo')
    'foo'

    :param element: instance of lxml.etree._Element
    :return:  string of local name
    """

    if isinstance(element, etree._Element):
        tag = element.tag
    else:
        tag = element
    d=re.match("(\{(?P<ns>.*)\})?(?P<localname>\w+)", tag)
    assert d, "Expected a successful match"
    return d.groupdict()["localname"]

def callouts(xmltree, cli, manifest):
    """Appends list of filenames for callout graphics

    :param xmltree: `etree.parse` instance
    :param cli:      instance of CLI argument parsing
    :param manifest: result list to append

    :return: None, but append everything to `manifest`
    """
    log.info("callouts")
    callout_graphics_path=cli.callout_path
    callout_graphics_extension=cli.callout_ext
    cl = xmltree.xpath("//calloutlist|//d:calloutlist",
                       namespaces=nsmap)
    comax = max([ len(i.getchildren()) for i in cl ])
    for i in range(1, comax+1):
        manifest.append("{}{}{}".format(callout_graphics_path,
                                        i,
                                        callout_graphics_extension))

def admonitions(xmltree, cli, manifest):
    """Appends list of filenames for admonition graphics

    :param xmltree: `etree.parse` instance
    :param cli:      instance of CLI argument parsing
    :param manifest: result list to append

    :return: None, but append everything to `manifest`
    """
    log.info("admonitions")
    admon_graphics_path=cli.admon_path
    admon_graphics_extension=cli.admon_ext
    admons = xmltree.xpath("""//d:caution|//caution|
                            //d:important|//important|
                            //d:note|//note|
                            //d:tip|//tip|
                            //d:warning|//warning""",
                           namespaces=nsmap)

    admonset={ "{}{}{}".format(admon_graphics_path,
                               localname(i.tag),
                               admon_graphics_extension)
               for i in admons }
    manifest.extend(admonset)


def selectmediaobjectindex(mediaobject, cli):
    """Select corect imageobjects from mediaobject

    :param mediaobject: list of mediaobject elements
    :param cli: parsed result from CLI ArgumentParser

    :return: integer number of 'good' imagedata
    """
    preferred_mediaobject_role=cli.preferred_mediaobject_role
    role="@role='{}'".format(preferred_mediaobject_role)

    mchildren = mediaobject.getchildren()

    # This is the default value:
    index = 0

    # Make it also compatible with DocBook5
    olist = "imageobject|imageobjectco|videoobject|audioobject|textobject"
    olist=olist.split("|")
    olist.extend([ "d:"+i for i in olist ])
    olist = "|".join(olist)

    for count, obj in enumerate(mchildren):
        tag=localname(obj.tag)
        role=obj.attrib.get("role")
        log.debug("  count={}, obj={} in {}".format(count, obj, obj.sourceline))
        log.debug("  tag={!r}".format(tag))
        log.debug("  role={!r}".format(role))
        if preferred_mediaobject_role == role:
            index = count
            break

    return index

def imagedata(xmltree, cli, manifest):
    """Appends list of filenames for ordinary graphics

    :param xmltree: `etree.parse` instance
    :param cli:      instance of CLI argument parsing
    :param manifest: result list to append

    :return: None, but append everything to `manifest`
    """
    log.info("imagedata")
    img_src_path=cli.img_src_path
    mediaobjects = xmltree.xpath("""//d:mediaobject|//mediaobject""",
                         namespaces=nsmap)

    for media in mediaobjects:
        idx = selectmediaobjectindex(media, cli)
        img = media.xpath("*[position() = {}]/*".format(idx))[0]
        log.debug("=> got index={}".format(idx))
        log.debug("=> got obj={}".format(img))
        print("{}{}".format(img_src_path,
                            img.attrib.get("fileref")))
        #for img in media.xpath("*/imagedata|*/d:imagedata", namespaces=nsmap):
        #    print("{}{}".format(img_src_path,
        #                        img.attrib.get("fileref")))


def main():
    cli = cliparse()
    xmlparser = defaultxmlparser()
    log.info("Arguments: {}".format(cli))

    manifest=[]
    for xmlfile in cli.files:
        try:
            xmltree = etree.parse(xmlfile, xmlparser)
            xmltree.xinclude()

            # Iterate through all interesting dependencies
            for func in (callouts, admonitions, imagedata):
                func(xmltree, cli, manifest)

        except etree.XMLSyntaxError as err:
            log.error(err)
            continue

    # manifest=list(set(manifest))
    log.debug("** Start creating manifest...")
    for i in sorted(manifest):
        print(i)

    log.debug("** End creating manifest.")

if __name__ == "__main__":
    main()

# EOF