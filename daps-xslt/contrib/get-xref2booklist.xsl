<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Prints ID information, wheather it's online or print
     
   Parameters:
     * xref.linkend
       Filter all ids. It prints the searched id only.
       
   Input:
     DocBook 4/Novdoc document
     
   Output:
     Text in the following format:
      id -> print|online
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:svg="http://www.w3.org/2000/svg">


<xsl:output method="text" encoding="UTF-8"/>

<xsl:key name="id" match="*" use="@id|@xml:id"/>
<xsl:param name="xref.linkend" select="''"/>


<xsl:template match="text()"/>

<xsl:template match="xref">
  <xsl:variable name="targets" select="key('id',@linkend)"/>
  <xsl:variable name="target" select="$targets[1]"/>
  <xsl:variable name="target.book" select="$target/ancestor-or-self::book"/>

  <xsl:message>
   <xsl:choose>
     <xsl:when test="$xref.linkend=''">
       <xsl:call-template name="print.online">
         <xsl:with-param name="target.book" select="$target.book"/>
       </xsl:call-template>
     </xsl:when>
     <xsl:otherwise>
       <xsl:choose>
         <xsl:when test="@linkend=$xref.linkend">
            <xsl:call-template name="print.online">
               <xsl:with-param name="target.book" select="$target.book"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
         </xsl:otherwise>
       </xsl:choose>
     </xsl:otherwise>
   </xsl:choose>
  </xsl:message>
</xsl:template>


<xsl:template name="print.online">
  <xsl:param name="target.book"/>

 <xsl:choose>
    <xsl:when test="$target.book/@role='print' or not(/set) or /article">
       <xsl:value-of select="@linkend"/>
       <xsl:text> -> print&#10;</xsl:text>
    </xsl:when>
    <xsl:when test="$target.book/@role='online'">
       <xsl:value-of select="@linkend"/>
       <xsl:text> -> online&#10;</xsl:text>
    </xsl:when>
    <xsl:otherwise>
       <xsl:text> ???&#10;</xsl:text>
    </xsl:otherwise>
 </xsl:choose>

</xsl:template>


</xsl:stylesheet>