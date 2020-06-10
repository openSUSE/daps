<?xml version="1.0" encoding="UTF-8"?>
<!--

  Purpose:
     Transform a DocBook5 document into an intermediate DocBook5
     document ready for consumption by pandoc.

   Usage:
     $ xsltproc db2db.xsl XMLFILE | pandoc -f docbook -t rst \
       -o /tmp/XMLFILENAME.rst -

     (Don't forget the dash in the previous line.)

   Parameters:
     None

   Input:
     DocBook5 document

   Output:
     DocBook5 document with the following changes:

     * procedure or substeps -> orderedlist
     * steps -> listitem

   See Also:
     man pandoc

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2020 SUSE Software Solutions Germany GmbH

-->

<xsl:stylesheet version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:d="http://docbook.org/ns/docbook"
   xmlns="http://docbook.org/ns/docbook">

   <xsl:import href="../common/copy.xsl"/>

   <xsl:template match="d:procedure|d:substeps">
      <orderedlist>
         <xsl:apply-templates select="@*|node()"/>
      </orderedlist>
   </xsl:template>

   <xsl:template match="d:step">
      <listitem>
         <xsl:apply-templates select="@*|node()"/>
      </listitem>
   </xsl:template>

</xsl:stylesheet>