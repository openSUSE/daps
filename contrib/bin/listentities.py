#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Lists all entities from an XML file
#
# Synopsis:
#   $ listentities.py XMLFILE
#
# HINTS:
# Currently, command line parsing doesn't occur. There are no
# --help|-h options.
#
# Copyright (C) 2017 SUSE Linux GmbH
#
# Author:
# Thomas Schraitle <toms at opensuse dot org>

import io
from lxml import etree
import lxml.sax
import os.path
import subprocess
import sys
import xml.sax


# Inheriting from EntityResolver and DTDHandler is not necessary
class TestHandler(lxml.sax.ContentHandler):
    def __init__(self):
        super().__init__()
        self.extentities = []

    # This method is only called for external entities. Must return a value.
    def resolveEntity(self, publicID, systemID):
        print("TestHandler.resolveEntity(): %s %s" % (publicID, systemID),
              file=sys.stderr)
        self.extentities.append((publicID, systemID))
        return systemID


def resolveURL(url, *, timeout=None, check=False):
    with subprocess.Popen(["xmlcatalog", "/etc/xml/catalog", url],
                          stdout=subprocess.PIPE) as process:
        try:
            stdout, stderr = process.communicate(timeout=timeout)
        except subprocess.TimeoutExpired:
            process.kill()
            stdout, stderr = process.communicate()
            raise subprocess.TimeoutExpired(process.args,
                                            timeout,
                                            output=stdout,
                                            stderr=stderr)
        except:
            process.kill()
            process.wait()
            raise
        retcode = process.poll()
        if check and retcode:
            raise subprocess.CalledProcessError(retcode,
                                                process.args,
                                                output=stdout,
                                                # stderr=stderr
                                                )
    return (stdout, stderr)


def expat(filename):
    parser = xml.sax.make_parser()
    handler = TestHandler()
    parser.setContentHandler(handler)
    parser.setEntityResolver(handler)
    parser.setDTDHandler(handler)
    #
    # parser.setFeature(xml.sax.handler.feature_validation, True)
    parser.setFeature(xml.sax.handler.feature_external_ges, True)
    # parser.setProperty(xml.sax.handler.property_declaration_handler, handler)

    parser.parse(filename)
    return handler.extentities


def iterentities(dtdfile):
    print("Parsing %r..." % dtdfile, file=sys.stderr)
    try:
        dtd = etree.DTD(dtdfile)
        yield from dtd.iterentities()
    except etree.DTDParseError:
        # Hmn, should we do that?
        pass


def main(filename):
    names = set()
    try:
        extentities = expat(filename)
        for public, system in extentities:
            identifier = system if public is None else public
            print("Trying to resolve %r..." % identifier, file=sys.stderr)
            print("Using %r" % extentities[:3], file=sys.stderr)

            try:
                stdout, stderr = resolveURL(identifier, check=True)
                identifier = stdout
            except subprocess.CalledProcessError as error:
                print("ERROR:", error, file=sys.stderr)
                identifier = system

            try:
                identifier = identifier.strip().decode("utf-8")
            except:
                pass
            if identifier.startswith('file:'):
                identifier = identifier[5:]

            if not os.path.isabs(identifier):
                # print("Trying to join: "
                #       "%r with %r" % (os.path.dirname(filename),
                #                       identifier),
                #                       file=sys.stderr)
                identifier = os.path.join(os.path.dirname(filename),
                                          identifier)
            for ent in iterentities(identifier):
                # print(ent.name, end=" ", file=sys.stderr)
                names.add(ent.name)

        return names

    except xml.sax.SAXParseException as e:
        print("*** PARSER error: %s" % e, file=sys.stderr)


if __name__ == "__main__":
    names = main(sys.argv[1])
    # print("-"*20)
    print(sorted(names))

# EOF
