<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Transforms output of svn pl -v ++xml into more consumable XML
     
   Parameters:
     None
       
   Input:
     XML file from "svn  pl -v ++xml" 
      <properties>
        <target path="xml/foo.xml">
          <property name="doc:priority">2</property>
          <property name="doc:status">editing</property>
          <property name="doc:deadline">2011-01-15</property>
          <property name="doc:trans">no</property>
          <property name="incgraphics">False</property>
        d</target>
      </properties>
     
   Output:
     XML file
     <filename priority="2"
               status="editing"
               deadline="2011-01-15"
               trans="no"
               incgraphics="False"
               >foo.xml</filename> 
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->

<xsl:stylesheet  version="1.0"
  xmlns="urn:x-suse:xmlns:docproperties"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  <xsl:strip-space elements="*"/>
 
  <xsl:template name="basename">
    <xsl:param name="path"/>
    <xsl:choose>
      <xsl:when test="contains($path, '/')">
        <xsl:call-template name="basename">
          <xsl:with-param name="path" select="substring-after($path, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$path"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
 
  <xsl:template match="properties">
    <docproperties version="1.0">
      <xsl:apply-templates/>
    </docproperties>
  </xsl:template>
 
  <xsl:template match="target">
    <filename>
      <xsl:apply-templates select="property"/>
      <!--Create relative filename, in case of absolute paths: -->
      <xsl:call-template name="basename">
        <xsl:with-param name="path" select="@path"/>
      </xsl:call-template>
    </filename>
  </xsl:template>

  <xsl:template match="property">
    <xsl:variable name="attrname">
      <xsl:choose>
        <xsl:when test="starts-with(@name, 'doc:')">
          <xsl:value-of select="substring-after(@name, 'doc:')"/>
        </xsl:when>
        <xsl:when test="contains(@name, ':')">
          <xsl:value-of select="translate(@name, ':', '_')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@name"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="{$attrname}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
</xsl:stylesheet>
