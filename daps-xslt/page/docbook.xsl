<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Creates a "page" XML output file which is compatible with
     project Mallard (see http://projectmallard.org)
     
   Parameters:
   
   
   Input:
     DocBook 4/Novdoc document
     
   Output:
     Page XML output according to the RELAX NG schema from 
     http://projectmallard.org/1.0/mallard-1.0.rnc
     
   Note:

-->
<!DOCTYPE xsl:stylesheet [
  <!ENTITY lowercase "'abcdefghijklmnopqrstuvwxyz'">
  <!ENTITY uppercase "'ABCDEFGHIJKLMNOPQRSTUVWXYZ'">
]>
<xsl:stylesheet version="1.0"
  xmlns="http://projectmallard.org/1.0/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:import href="../common/rootid.xsl"/>
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>
  
  <xsl:param name="productid">
    <xsl:call-template name="discard.space">
      <xsl:with-param name="string">
        <xsl:call-template name="string.lower">
          <xsl:with-param name="string" select="normalize-space(*/*/productname)"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  
  
  <xsl:template name="string.lower">
    <xsl:param name="string" select="''"/>
    <xsl:value-of select="translate($string,&uppercase;,&lowercase;)"/>
  </xsl:template>
  <xsl:template name="discard.space">
    <xsl:param name="string" select="''"/>
    <xsl:value-of select="translate($string, ' ', '')"/>
  </xsl:template>
  
  <xsl:template name="create-info">
    <xsl:param name="node" select="."/>
    <xsl:param name="subnodes" select="book"/>
    
    <info>
      <link type="guide" xref="index" group="{$productid}"/>      
      <credit type="author">
        <name>Documentation Team</name>
        <email>doc-team@suse.de</email>
      </credit>
      
      <desc>
        <xsl:value-of select="normalize-space(*/productname)"/> comes
        with the following books and guides:
        <xsl:apply-templates select="$subnodes"/>
      </desc>
    </info>
  </xsl:template>
  
  
  <xsl:template match="/">
    <xsl:processing-instruction name="xml-model"
      >href="mallard-1.0.rnc" type="application/relax-ng-compact-syntax"</xsl:processing-instruction>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="/set">
    <xsl:param name="node" select="."/>
    <page type="guide" id="{$productid}">
      <xsl:call-template name="create-info"/>
      <title>
        <xsl:apply-templates select="(*/title|title)[1]"/>
      </title>
      <p>
       <link href="help:opensuse-manuals">The complete set of 
         <xsl:value-of select="normalize-space(*/productname)"/> documents</link> 
        consists of the following books and guide:
      </p>
      <xsl:apply-templates mode="summary"/>
    </page>
  </xsl:template>
  
  
  <xsl:template match="/book">
    <page type="guide" id="{$productid}">
      <xsl:call-template name="create-info">
        <xsl:with-param name="subnodes"
          select="article|chapter|preface|appendix|glossary"/>
      </xsl:call-template>
      <title>
        <xsl:apply-templates select="(bookinfo/title|title)[1]"/>
      </title>
      <p>
       <link href="help:opensuse-manuals">The complete set of 
         <xsl:value-of select="normalize-space(*/productname)"/> documents</link> 
        consists of the following books and guide:
      </p>
      <xsl:apply-templates mode="summary"/>
    </page>
  </xsl:template>
  
  <xsl:template match="book">
    <xsl:param name="node" select="."/>
    <link xref="{$productid}#{@id}">
      <xsl:apply-templates select="(*/title|title)[1]"/>
    </link>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="book[article]">
    <xsl:apply-templates select="book/article"/>
  </xsl:template>
  
  <xsl:template match="book/article">
    <xsl:param name="node" select="."/>
    <link xref="{$productid}#{@id}">
      <xsl:apply-templates select="(*/title|title)[1]"/>
    </link>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="*" mode="summary"/>
  
  <xsl:template match="book" mode="summary">
    <xsl:param name="node" select="."/>
    <section id="{@id}">
      <title>
        <link href="help:opensuse-manuals">
          <xsl:apply-templates select="(*/title|title)[1]"/>
        </link>
      </title>
      <xsl:if test="*/abstract">
        <xsl:apply-templates select="*/abstract"/>
      </xsl:if>
    </section>
  </xsl:template>
  
  <xsl:template match="book[article]" mode="summary">
    <xsl:apply-templates select="book/article"/>
  </xsl:template>
  
  <xsl:template match="book/article" mode="summary">
    <xsl:param name="node" select="."/>
    <section id="{@id}">
      <title>
        <link href="help:opensuse-manuals">
          <xsl:apply-templates select="(*/title|title)[1]"/>
        </link>
      </title>
      <xsl:if test="*/abstract">
        <xsl:apply-templates select="*/abstract"/>
      </xsl:if>
    </section>
  </xsl:template>
  
  <xsl:template match="abstract/para">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <xsl:template match="abstract/para/emphasis">
    <em>
      <xsl:apply-templates/>
    </em>
  </xsl:template>
  
  <xsl:template match="para/quote">
    <xsl:text>"</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>"</xsl:text>
  </xsl:template>
  
  <xsl:template match="para/systemitem">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="abstract/*|para/*">
    <xsl:message>Unknown element <xsl:value-of 
      select="local-name()"/> in <xsl:value-of select="local-name(..)"/>
    </xsl:message>
  </xsl:template>
    
</xsl:stylesheet>