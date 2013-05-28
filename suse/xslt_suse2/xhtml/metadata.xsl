<?xml version="1.0" encoding="ASCII"?>
<!-- 
   Purpose:  Inserts Meta information
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:dp="urn:x-suse:xmlns:docproperties"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns="http://www.w3.org/1999/xhtml"
  extension-element-prefixes="date"
  exclude-result-prefixes="date">

 <!-- Use a key to find the node dp:filename in 'METAFILE' -->
 <xsl:param name="metafilename" select="'METAFILE'"/>
 <xsl:key name="status" match="dp:filename" use="self::dp:filename"/>

  <xsl:template name="titlepage.timestamp">
    <xsl:variable name="format">
      <xsl:call-template name="gentext.template">
        <xsl:with-param name="context" select="'datetime'"/>
        <xsl:with-param name="name" select="'titlepage.format'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="date">
      <xsl:choose>
        <xsl:when test="function-available('date:date-time')">
          <xsl:value-of select="date:date-time()"/>
        </xsl:when>
        <xsl:when test="function-available('date:dateTime')">
          <!-- Xalan quirk -->
          <xsl:value-of select="date:dateTime()"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <p class="ds-message">
      Last built on
      <xsl:call-template name="datetime.format">
        <xsl:with-param name="date" select="$date"/>
        <xsl:with-param name="format" select="$format"/>
        <xsl:with-param name="padding" select="1"/>
      </xsl:call-template>
    </p>
  </xsl:template>

<xsl:template name="getmetadata">
 <xsl:param name="filename" select="'UNKNOWN'"/>

 <xsl:variable name="metafilenodes" select="document($metafilename,.)/*/dp:filename"/>
 <xsl:variable name="dpfilenamenode" select="$metafilenodes[generate-id(.) =   generate-id(key('status', $filename))]"/>
  <div class="doc-status">
   <xsl:choose>
    <xsl:when test="count($dpfilenamenode) = 0 and $filename != ''">
     <xsl:message>WARNING: Could not retrieve metadata for filename 
      <xsl:value-of select="concat(&quot;'&quot;, $filename, &quot;' &quot;)"/>.
      Type &quot;man docmanager&quot; to learn more.</xsl:message>
      <p class="ds-message">No Status Information available.</p>
    </xsl:when>
    <xsl:otherwise>
      <span class="ds-head">Status information</span>
      <ul>
       <li><span class="ds-label">Filename: </span><xsl:value-of select="$filename"/></li>
       <li><span class="ds-label">Maintainer: </span><xsl:value-of select="$dpfilenamenode/@maintainer"/></li>
       <li>
         <span class="ds-label">Status: </span><xsl:value-of select="$dpfilenamenode/@status"/>
         <xsl:if test="$dpfilenamenode/@prelim = 'yes'">
           <xsl:text>, preliminary</xsl:text>
         </xsl:if>
       </li>
      </ul>
    </xsl:otherwise>
   </xsl:choose>
  <xsl:call-template name="titlepage.timestamp"/>
  </div>
</xsl:template>

<xsl:template name="metadata">
            <xsl:if test="$use.meta != 0">
              <!--
                On every structural element (like chapter, preface, ...) we
                have a xml:base attribute pointing to the filename
                If it isn't available, we point to the book filename
              -->
              <xsl:variable name="xmlbase.filename">
                <xsl:variable name="_xmlbase" 
                  select="(ancestor-or-self::chapter|
                  ancestor-or-self::preface|
                  ancestor-or-self::appendix|
                  ancestor-or-self::glossary)/@xml:base"/>
                <xsl:choose>
                  <xsl:when test="$_xmlbase != ''">
                    <xsl:value-of select="$_xmlbase"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="ancestor-or-self::book/@xml:base"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:comment>htdig_noindex</xsl:comment>
              <xsl:call-template name="getmetadata">
                <xsl:with-param name="filename" select="$xmlbase.filename"/>
              </xsl:call-template>
              <xsl:comment>/htdig_noindex</xsl:comment>
            </xsl:if>
</xsl:template>

</xsl:stylesheet>
