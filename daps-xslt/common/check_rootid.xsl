<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Provides basic templates for applying a stylesheet only to fraction
     of the document
     
   Parameters:
     * rootid
       Applies stylesheet only to part of the document

   Input:
     DocBook 4/Novdoc document
     
   Output:
     yes: rootid exists
     no:  rootid does not exist
   
   Author:    Frank Sundermeyer <fsundermeyer@opensuse.org>
   Copyright: 2012, Frank Sundermeyer
   
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 <xsl:key name="id" match="*" use="@id|@xml:id"/>
 <xsl:param name="rootid"/>

 <xsl:output method="text"/>
 
 <xsl:template match="/">
  <xsl:if test="$rootid =''">
   <xsl:message terminate="yes">
    <xsl:text>Please specify a rootid!</xsl:text>
   </xsl:message>
  </xsl:if>
  <xsl:choose>
   <xsl:when test="count(key('id',$rootid)) = 0">
    <xsl:text>no</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>yes</xsl:text>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>
