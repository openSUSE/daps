<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook">

  <xsl:import href="db5to4-core.xsl"/>
  <xsl:import href="db5to4-info.xsl"/>

  <xsl:output method="xml" indent="yes"
    doctype-public="-//OASIS//DTD DocBook XML V4.5//EN"
    doctype-system="http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd"/>


  <!-- ================================================================= -->
  <!-- Taken from common/common.xsl -->
  <xsl:template name="filename-basename">
    <!-- We assume all filenames are really URIs and use "/" -->
    <xsl:param name="filename"></xsl:param>
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
  
  <!-- Taken from https://github.com/stackforge/clouddocs-maven-plugin/blob/a3621dfb4b620f3993d826649f7b944dae4b2407/src/main/resources/cloud/webhelp/profile-webhelp.xsl#L242
       and adapted to DocBook4
  -->
  <xsl:template name="CCLegalNotice">
    <xsl:if test="starts-with(string(@role),'cc-')">
      <xsl:variable name="ccid">
        <xsl:value-of select="substring-after(string(@role),'cc-')"/>
      </xsl:variable>
      <xsl:variable name="ccidURL"
        >http://creativecommons.org/licenses/<xsl:value-of
          select="$ccid"/>/3.0/legalcode</xsl:variable>
      <informaltable frame="void">
        <col width="10%"/>
        <col width="90%"/>
        <tbody>
          <tr>
            <td>
              <ulink url="{$ccidURL}">
                <inlinemediaobject>
                  <imageobject>
                    <imagedata fileref="{$ccid}.png"/>
                  </imageobject>
                </inlinemediaobject>
              </ulink>
            </td>
            <td>
              <para>Except where otherwise noted, this document is
                licensed under <ulink url="{$ccidURL}">                  
                  <emphasis role="bold"> Creative Commons Attribution <xsl:choose>
                    <xsl:when test="$ccid = 'by'"/>
                    <xsl:when test="$ccid = 'by-sa'">
                      <xsl:text>ShareAlike</xsl:text>
                    </xsl:when>
                    <xsl:when test="$ccid = 'by-nd'">
                      <xsl:text>NoDerivatives</xsl:text>
                    </xsl:when>
                    <xsl:when test="$ccid = 'by-nc'">
                      <xsl:text>NonCommercial</xsl:text>
                    </xsl:when>
                    <xsl:when test="$ccid = 'by-nc-sa'">
                      <xsl:text>NonCommercial ShareAlike</xsl:text>
                    </xsl:when>
                    <xsl:when test="$ccid = 'by-nc-nd'">
                      <xsl:text>NonCommercial NoDerivatives</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:message terminate="yes"> I don't understand
                        licence <xsl:value-of select="$ccid"/>
                      </xsl:message>
                    </xsl:otherwise>
                  </xsl:choose> 3.0 License </emphasis>
                </ulink> 
              </para>
              <para>
                <ulink url="{$ccidURL}"/>
              </para>
            </td>
          </tr>
        </tbody>
      </informaltable>
    </xsl:if>
  </xsl:template>
  
  
  <!-- ================================================================= -->
  <xsl:template match="/">
    <xsl:processing-instruction name="xml-stylesheet">
      href="urn:x-daps:xslt:profiling:docbook45-profile.xsl" 
      type="text/xml"
      title="Profiling step"</xsl:processing-instruction>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="/*[not(@xml:lang)]">
    <xsl:element name="{local-name()}">
      <xsl:attribute name="lang">en</xsl:attribute><!-- Set default value -->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>


  <!-- Rewrite @audience -> condition -->
  <xsl:template match="@audience">
    <xsl:attribute name="condition">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
  
  <xsl:template match="d:author[d:affiliation]">
    <xsl:apply-templates select="*[not(self::d:affiliation)]"/>
    <xsl:element name="corpauthor">
      <xsl:apply-templates select="d:affiliation/*"/>
    </xsl:element>
  </xsl:template>


  <xsl:template match="d:affiliation/d:orgname">
    <!-- We don't need this, so skip it: -->
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="d:legalnotice">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@role"/>
      <para><!-- We need para here unfortunately -->
        <xsl:call-template name="CCLegalNotice"/>
      </para>
    </xsl:element>
  </xsl:template>


  <xsl:template match="d:legalnotice/*"/>

  
  <xsl:template match="d:imagedata/@fileref">
    <xsl:variable name="basename">
      <xsl:call-template name="filename-basename">
        <xsl:with-param name="filename" select="."/>
        <xsl:with-param name="recurse" select="true()"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:attribute name="fileref">
      <xsl:value-of select="$basename"/>
    </xsl:attribute>
  </xsl:template>


  <xsl:template match="d:imagedata/@contentwidth">
    <xsl:choose>
      <xsl:when test="not(@width)">
        <xsl:attribute name="width">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="../@width = ."/>
      <xsl:otherwise>
        <xsl:attribute name="contentwidth">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="d:imagedata/@format"/>

</xsl:stylesheet>
