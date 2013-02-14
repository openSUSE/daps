<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Transform DocBook document into XSL-FO file
     
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
  <xsl:include href="pagesetup.xsl"/>


  <xsl:include href="attributesets.xsl"/>

</xsl:stylesheet>
