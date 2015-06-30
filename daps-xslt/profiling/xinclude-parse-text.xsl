<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Make relative paths for xi:include/@parse='text'
     
   BUGS:
     Does not support URIs/URNs yet

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2015 SUSE Linux GmbH

-->
<xsl:stylesheet 
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <!-- Taken from common/common.xsl -->
  <xsl:template name="filename-basename">
    <!-- We assume all filenames are really URIs and use "/" -->
    <xsl:param name="filename"/>
    <xsl:param name="recurse" select="false()"/>
    
    <xsl:choose>
      <xsl:when test="substring-after($filename, '/') != ''">
        <xsl:call-template name="filename-basename">
          <xsl:with-param name="filename"
            select="substring-after($filename, '/')"/>
          <xsl:with-param name="recurse" select="true()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$filename"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Rewrite only xi:include elements which contains parse='text' attribute.
       DAPS handles that and copies all relevant files
  -->
  <xsl:template match="xi:include[@parse='text']" mode="profile"
                name="xinclude-text">
    <xsl:copy>
      <!-- Remove any common profiling attributes;
           recreate href attribute
      -->
      <xsl:copy-of select="@xpointer|@accept|@accept-language|@parse|@encoding"/>
      <xsl:attribute name="href">
        <xsl:call-template name="filename-basename">
          <xsl:with-param name="filename" select="@href"/>
        </xsl:call-template>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>