<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: $ -->
<!DOCTYPE xsl:stylesheet >
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >


<xsl:template match="refnamediv" mode="title.markup">
  <xsl:apply-templates select="refname"/>
</xsl:template>

<xsl:template match="guilabel|guimenu|guibutton|keycombo|keycap|menuchoice" mode="title.markup">
  <xsl:apply-templates select="self::node()"/>
</xsl:template>

<xsl:template match="xref" mode="title.markup">
  <xsl:call-template name="xref"/>
</xsl:template>
  
<!--
   Temporary fix for version 1.78.1:
   See upstream revision 9820. Remove this snippet, if there is a newer 
   version available.

   TODO: Currently, with this template xsltproc detects a recursion. 
         I disabled the template for the time being, but we need to 
         investigate it further.
-->
  
<<!--xsl:template match="ulink" mode="no.anchor.mode">
  <xsl:param name="url" select="@url"/>
  <xsl:choose>
    <xsl:when test="count(child::node())=0">
      <xsl:value-of select="$url"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>-->
  
</xsl:stylesheet>

