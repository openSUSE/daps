<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

<!-- 
  This template is not availabe in the 10.2 DocBook stylesheets
-->
<xsl:template name="pi.dbhtml_filename">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'filename'"/>
  </xsl:call-template>
</xsl:template>
  
<xsl:template match="processing-instruction('suse')" 
              mode="titlepage.mode">
  <xsl:call-template name="suse-pi"/>
</xsl:template>

<xsl:template match="processing-instruction('suse')" mode="title.markup">
  <xsl:call-template name="suse-pi"/>
</xsl:template>

<xsl:template match="processing-instruction('suse')" mode="titleabbrev.markup">
  <xsl:call-template name="suse-pi"/>  
</xsl:template>


<xsl:template match="title/processing-instruction('suse')" mode="object.title.markup">
  <xsl:message>PI('suse')(object.title.markup): <xsl:value-of select="."/></xsl:message>
  <xsl:call-template name="suse-pi"/>
</xsl:template>


<xsl:template match="processing-instruction('suse')">
  <xsl:call-template name="suse-pi"/>  
</xsl:template>

</xsl:stylesheet>
