<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Transform DocBook document into chunked XHTML files
     
   Parameters:
     Too many to list here, see here:
     http://docbook.sourceforge.net/release/xsl/current/doc/html/index.html
       
   Input:
     DocBook 4/5 document
     
   Output:
     Chunked XHTML files
     
   See Also:
     * http://doccookbook.sf.net/html/en/dbc.common.dbcustomize.html
     * http://sagehill.net/docbookxsl/CustomMethods.html#WriteCustomization

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->

<!DOCTYPE xsl:stylesheet
[
  <!ENTITY www "http://docbook.sourceforge.net/release/xsl/current/xhtml">
]>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    exclude-result-prefixes="exsl l t">

  <xsl:import href="docbook.xsl"/> 

  <!-- FIXME: Better use a full URL for catalog-based resolution here? The
       caveat of doing that would of course be possible dependency issues,
       since we generally want matching stylesheets not any and all that are
       installed on the system. -->
  <xsl:import href="../suse2013/xhtml/chunk.xsl"/>

</xsl:stylesheet>
