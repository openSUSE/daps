<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Transform DocBook document into XSL-FO file

    The page layout is based upon a grid of eight columns (the leftmost and
    rightmost column function as margins), each 22.5 mm wide, and five gutters,
    each 6 mm wide:
    |   C1  |  C2  |G1|  C3  |G2|  C4  |G3|  C5  |G4|  C6  |G5|  C7  |  C8  |

  Parameters:
    Too many to list here, see:
    http://docbook.sourceforge.net/release/xsl/current/doc/fo/index.html

  Input:
    DocBook 4/5 document

   Output:
     XSL-FO file

  Authors:    Thomas Schraitle <toms@opensuse.org>,
              Stefan Knorr <sknorr@suse.de>
  Copyright:  2013, Thomas Schraitle, Stefan Knorr

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="exsl">

  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl"/>
  
  <xsl:include href="param.xsl"/>
  <xsl:include href="../common/titles.xsl"/>
  <xsl:include href="../common/navigation.xsl"/>
  
  <xsl:include href="autotoc.xsl"/>
  <xsl:include href="callout.xsl"/>
  <xsl:include href="xref.xsl"/>
  <xsl:include href="sections.xsl"/>
  <xsl:include href="table.xsl"/>
  <xsl:include href="htmltbl.xsl"/>
  <xsl:include href="inline.xsl"/>
  <xsl:include href="division.xsl"/>
  <xsl:include href="admon.xsl"/>
  <xsl:include href="component.xsl"/>
  <xsl:include href="titlepage.templates.xsl"/>
  <xsl:include href="pagesetup.xsl"/>


  <xsl:include href="attributesets.xsl"/>
  <xsl:include href="lists.xsl"/>
  <xsl:include href="l10n.properties.xsl"/>

  <xsl:include href="fop1.xsl"/>
  <xsl:include href="xep.xsl"/>

</xsl:stylesheet>
