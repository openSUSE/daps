<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Transform DocBook document into single XHTML file
     
   Parameters:
     Too many to list here, see:
     http://docbook.sourceforge.net/release/xsl/current/doc/html/index.html
       
   Input:
     DocBook 4/5 document
     
   Output:
     Single XHTML file
     
   See Also:
     * http://doccookbook.sf.net/html/en/dbc.common.dbcustomize.html
     * http://sagehill.net/docbookxsl/CustomMethods.html#WriteCustomization

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	exclude-result-prefixes="exsl">
  
 <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl"/>
 
 <xsl:include href="../common/titles.xsl"/>
 
 <xsl:include href="param.xsl"/>
 <xsl:include href="create-permalink.xsl"/>
 
 <xsl:include href="autotoc.xsl"/>
 <xsl:include href="lists.xsl"/>
 <xsl:include href="verbatim.xsl"/>
 <xsl:include href="component.xsl"/>
 <xsl:include href="formal.xsl"/>
 <xsl:include href="sections.xsl"/>
 <xsl:include href="division.xsl"/>
 <xsl:include href="inline.xsl"/>
 <xsl:include href="admon.xsl"/>
 <xsl:include href="titlepage.templates.xsl"/>

 <xsl:include href="metadata.xsl"/>
</xsl:stylesheet>
