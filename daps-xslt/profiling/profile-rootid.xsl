<?xml version="1.0" encoding="UTF-8"?>


<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

<xsl:template name="pre.rootnode">
  <!-- intentionally empty -->
</xsl:template>

<xsl:template name="post.rootnode">
  <!-- intentionally empty -->
</xsl:template>


<xsl:template match="/">
  <xsl:call-template name="pre.rootnode"/>
<!--  
   <xsl:variable name="_comment.msg">
     <xsl:text> HINT: Comments are</xsl:text>
     <xsl:choose>
       <xsl:when test="$keep.xml.comments != 0">
         <xsl:text> ON&#10;</xsl:text>
       </xsl:when>
       <xsl:otherwise>
         <xsl:text> OFF&#10;</xsl:text>
       </xsl:otherwise>
     </xsl:choose>
   </xsl:variable>

   <xsl:message><xsl:value-of select="$_comment.msg"/></xsl:message>
-->
  <xsl:comment>
<!--
*********************************
This document is licenced under the GNU Free Documentation License

See LICENSE.txt for more details
*********************************
-->
*********************************
Please see LICENSE.txt for this document's license.
*********************************
</xsl:comment>

  <xsl:choose>
      <xsl:when test="$rootid != ''">
        <xsl:choose>
          <xsl:when test="count(key('id',$rootid)) = 0">
            <xsl:message terminate="yes">
              <xsl:text>ID '</xsl:text>
              <xsl:value-of select="$rootid" />
              <xsl:text>' not found in document.</xsl:text>
            </xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="key('id',$rootid)" mode="profile"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-imports/>
      </xsl:otherwise>
    </xsl:choose>
  <xsl:call-template name="post.rootnode"/>
</xsl:template>


</xsl:stylesheet>
