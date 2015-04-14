<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Collection of templates to search, retrieve, or delete attribute
     names in a node

   Parameters:
     None

   Input:
     Depends on the function

   Output:
     Depends on the function
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH

-->
<!-- $Id: attributes.xsl 2067 2005-09-14 11:34:30Z toms $ -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exslt="http://exslt.org/common"
    exclude-result-prefixes="exslt">

<xsl:template name="if.attribute.exists">
   <xsl:param name="name"/>
   <xsl:param name="node"/>

   <xsl:choose>
      <xsl:when test="contains($node, $name)">
         <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:value-of select="false()"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>


<xsl:template name="get.attribute.value">
   <xsl:param name="name"/>
   <xsl:param name="node"/>

   <xsl:variable name="result">
      <xsl:call-template name="if.attribute.exists">
      <xsl:with-param name="node" select="@node"/>
      <xsl:with-param name="name" select="$name"/>
      </xsl:call-template>
   </xsl:variable>

   <xsl:choose>
      <xsl:when test="$result">
         <xsl:value-of select="substring-before(substring-after($node, concat($name, ':')), ';')"/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>


<xsl:template name="delete.attribute.name">
   <xsl:param name="node"/>
   <xsl:param name="name"/>

   <xsl:choose>
      <xsl:when test="contains($node, $name)">
         <xsl:variable name="_after" select="substring-after($node, concat($name, ':'))"/>
         <xsl:variable name="before" select="substring-before($node, concat($name, ':'))"/>
         <xsl:variable name="after">
            <xsl:choose>
               <xsl:when test="contains($_after, ';')">
                  <xsl:value-of select="substring-after($_after, ';')"/>
               </xsl:when>
               <xsl:otherwise>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>

         <xsl:value-of select="concat($before, $after)"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:value-of select="$node"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>


<xsl:template name="delete.attribute.names">
   <xsl:param name="node"/>
   <xsl:param name="names"/>

   <xsl:variable name="before" select="substring-before($names, ' ')"/>
   <xsl:variable name="after"  select="substring-after($names, ' ')"/>


   <xsl:choose>
      <xsl:when test="$names != ''">
         <xsl:call-template name="delete.attribute.names">
            <xsl:with-param name="node">
               <xsl:call-template name="delete.attribute.name">
                  <xsl:with-param name="node" select="$node"/>
                  <xsl:with-param name="name">
                     <xsl:choose>
                        <xsl:when test="$before=''">
                           <xsl:value-of select="$names"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="$before"/>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:with-param>
               </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="names" select="$after"/>
         </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
         <xsl:value-of select="$node"/>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

</xsl:stylesheet>
