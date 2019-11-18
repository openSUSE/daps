Quickstart
==========

The script `getentityname.py` extracts all referenced entities of a XML files.


Why?
----

Although most XML parsers can retrieve the information from the DOCTYPE,
they usually are missing APIs to access the *internal subset* of the DTD.

An internal subset looks is everything between the square brackets:

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

