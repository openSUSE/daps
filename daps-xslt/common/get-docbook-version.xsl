<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Copy nodes
     
   Parameters:
     None
       
   Input:
     A DocBook 4 or DocBook 5 document
     
   Output:
     Text output
     * 4 = DocBook version 4
     * 5 = DocBook version 5
     * 0 = No DocBook document at all, something different
     
   CAVEAT:
     It is assumed, the root element contains either the DocBook 5
     namespace or is one of the structural elements (book, chapter, ...)
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH
   
-->
<xsl:stylesheet version="1.0"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="d">
  
  <xsl:output method="text"/>
  
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="d:*">5</xsl:when>
      <xsl:when test="appendix or article or 
                      book or bridgehead or 
                      chapter or colophon or
                      dedication or glossary or index or
                      lot or preface or reference or refentry or refsect1 or
                      refsect2 or refsect3 or refsection or
                      sect1 or sect2 or sect3 or sect4 or sect5 or
                      section or set or simplesect or toc">4</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template> 
</xsl:stylesheet>
