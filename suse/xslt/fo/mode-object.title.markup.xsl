<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     By default, the title of a formal object (procedure, table, figure,
     example) is all bold.
     This template can create different styling for the label and title
     separately
   
   Mode:
     * object.title.markup
   
   Parameters:
     * allow-anchors (default 0)
       Creates id attribute and consistent ID value, if allow-anchors is != 0

   Used Attribute Sets:
     * formal.inline.number.properties
       FO attributes for styling the number/label
     * formal.inline.title.properties
       FO attributes for styling the title

   Output:
     fo:block which contains the styling information for both
     label and title

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->

<xsl:stylesheet version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:fo="http://www.w3.org/1999/XSL/Format">
  
  
   <xsl:template match="procedure|table|figure|example" mode="object.title.markup">
      <xsl:param name="allow-anchors" select="0"/>
      
      <xsl:variable name="label.label">
         <xsl:call-template name="substitute-markup">
            <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
            <xsl:with-param name="template">
               <xsl:call-template name="gentext.template">
                  <xsl:with-param name="context" select="'styles'"/>
                  <xsl:with-param name="name"
                     select="concat(name(.), '-label')"/>
               </xsl:call-template>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="label.title">
         <xsl:call-template name="substitute-markup">
            <xsl:with-param name="allow-anchors" select="$allow-anchors"/>
            <xsl:with-param name="template">
               <xsl:call-template name="gentext.template">
                  <xsl:with-param name="context" select="'styles'"/>
                  <xsl:with-param name="name"
                     select="concat(name(.), '-title')"/>
               </xsl:call-template>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:variable>
      
      <xsl:choose>
         <xsl:when test="$xep.extensions != 0">
            <fo:block intrusion-displace="block">
               <fo:float float="start"><fo:block><fo:inline margin-right="1em"
                  xsl:use-attribute-sets="formal.inline.number.properties"
                  ><xsl:value-of select="$label.label"/></fo:inline></fo:block></fo:float>
               <fo:inline xsl:use-attribute-sets="formal.inline.title.properties"
                  ><xsl:value-of select="normalize-space($label.title)"/></fo:inline>
            </fo:block>
         </xsl:when>
         <xsl:otherwise>
            <fo:block>
               <fo:inline margin-right="1em"
                  xsl:use-attribute-sets="formal.inline.number.properties"
                  ><xsl:value-of select="$label.label"/></fo:inline>
               <xsl:text> </xsl:text>
               <fo:inline xsl:use-attribute-sets="formal.inline.title.properties"
                  ><xsl:value-of select="normalize-space($label.title)"/></fo:inline>
            </fo:block>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

</xsl:stylesheet>