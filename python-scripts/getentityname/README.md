Quickstart
==========

[![Test Python Script](https://github.com/tomschr/getentities/actions/workflows/pythonpackage.yml/badge.svg)](https://github.com/tomschr/getentities/actions/workflows/pythonpackage.yml)

The script `getentityname.py` extracts all referenced entities of a XML files.


Why?
----

Although most XML parsers can retrieve the information from the DOCTYPE,
parser APIs are mostly missing access to the *internal subset* of the DTD.

An internal subset is everything between the square brackets:

```xml
<!DOCTYPE book PUBLIC
      "-//OASIS//DTD DocBook XML V4.4//EN"
      "http://www.docbook.org/xml/4.4/docbookx.dtd"
 [
   <!-- The external subset -->
   <!ENTITY % entities SYSTEM "entity-decl.ent">
   %entities;
   <!ENTITY % foo SYSTEM "foo.ent">
   %foo;
 ]>
<book> <!-- ... --> </book>
```


Design
------

The script performs the following steps:

1. Parse the XML file with the SAX parser to make sure it's well-formed.
   This makes it a little bit easier to parse for corner cases.
   Additionally, the following steps can be made easier as we can expect a
   well-formed XML file.
1. Read the DOCTYPE header and identify the internal subset of the DTD.
1. Remove XML comments from the internal subset.
1. Identify parameter entities in the internal subset.
1. Load the file and search for other parameter entities.
1. Return all found parameter entities back to the user.


How to run it
-------------

Applying the script to the above XML file returns:

```
$ getentityname.py XMLFILE.xml
entity-decl.ent foo.ent
```

