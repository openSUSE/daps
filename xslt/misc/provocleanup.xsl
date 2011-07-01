<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   version="1.0">

   <xsl:output method="xml" indent="yes"/>

   <xsl:include href="../common/xpath.location.xsl"/>

   <xsl:template match="*">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>

   <xsl:template name="print.debug">
      <xsl:param name="text"/>
      <xsl:param name="showcontents" select="1"/>

      <xsl:message>
         <xsl:text>* Issue: </xsl:text>
         <xsl:value-of select="$text"/>
         <xsl:text>&#10;  XPath: </xsl:text>
         <xsl:call-template name="xpath.location"/>
         <xsl:if test="$showcontents != 0">
            <xsl:text/>
            <xsl:value-of
               select="concat(' = &quot;', normalize-space(.), '&quot;')"
            />
         </xsl:if>
      </xsl:message>
   </xsl:template>

<!--
   #################################################################### -->
   <xsl:template match="bridgehead">
      <xsl:call-template name="print.debug">
         <xsl:with-param name="text">
            <xsl:text>Removed bridgehead and inserted a comment.</xsl:text>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:comment>bridgehead: <xsl:value-of select="normalize-space(.)"/></xsl:comment>
   </xsl:template>
   
   <xsl:template match="chapter[@role='nld']">
      <chapter>
         <xsl:copy-of select="@*[ name() != 'role' ]"/>
         <xsl:apply-templates/>
      </chapter>
   </xsl:template>
   
   <xsl:template match="figure[@pgwide='0']">
      <figure>
         <xsl:copy-of select="@*[name() != 'pgwide']"/>
         <xsl:apply-templates/>
      </figure>
   </xsl:template>
   
   <xsl:template match="formalpara/title">
      <title>        
         <xsl:variable name="text" select="."/>
         <xsl:variable name="len" select="string-length($text)"/>
         <xsl:variable name="lastchar" select="substring($text, $len, 1)"/>
         
         <xsl:copy-of select="@*"/>
                  
         <xsl:choose>
            <xsl:when test="$lastchar = ':' or $lastchar = '.'">
               <xsl:value-of select="substring($text, 1, $len -1)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:copy-of select="$text"/>
            </xsl:otherwise>
         </xsl:choose>
      </title>
   </xsl:template>
   
   <xsl:template match="mediaobject">
      <mediaobject>
      <xsl:choose>
         <xsl:when test="count(imageobject) = 2">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
            <xsl:comment>FIXME: Fix this imageobject </xsl:comment>
            <imageobject>
               <imagedata fileref="UNKNOWN" width="???"/>
            </imageobject>
         </xsl:otherwise>
      </xsl:choose>
      </mediaobject>
   </xsl:template>

   <xsl:template match="imagedata">
      <imagedata>
         <xsl:copy-of select="@*[ name() != 'width' ]"/>
         <xsl:attribute name="width">
            <xsl:choose>
               <xsl:when test="@width = ''">
                  <xsl:call-template name="print.debug">
                     <xsl:with-param name="text">Attribute @width can
                        not be empty.</xsl:with-param>
                  </xsl:call-template>
                  <xsl:text>FIXME</xsl:text>
               </xsl:when>
               <xsl:when test="contains(@width, ' ')">
                  <xsl:call-template name="print.debug">
                     <xsl:with-param name="text">Attribute @width must
                        not contain spaces.</xsl:with-param>
                  </xsl:call-template>
                  <xsl:value-of select="normalize-space(@width)"/>
               </xsl:when>
               <xsl:when test="not(contains(@width, '%'))">
                  <xsl:call-template name="print.debug">
                     <xsl:with-param name="text">Attribute @width should
                        contain a percentage value.</xsl:with-param>
                  </xsl:call-template>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="@width"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:attribute>
      </imagedata>
   </xsl:template>

   <xsl:template match="itemizedlist[@role='subtoc']" priority="2">
      <xsl:call-template name="print.debug">
         <xsl:with-param name="showcontents" select="0"/>
         <xsl:with-param name="text">
            <xsl:text>This itemizedlist was removed.</xsl:text>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:text>&#10;</xsl:text>
      <xsl:comment>itemizedlist @role='subtoc' removed</xsl:comment>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="itemizedlist[@*]">
      <itemizedlist>
         <xsl:copy-of
            select="@*[name() != 'spacing' and 
                       name() != 'mark']"/>

         <xsl:if test="@mark != 'bullet'">
            <xsl:attribute name="mark">
               <xsl:value-of select="@mark"/>
            </xsl:attribute>
         </xsl:if>
         <xsl:if test="@spacing != 'normal'">
            <xsl:attribute name="spacing">
               <xsl:value-of select="@spacing"/>
            </xsl:attribute>
         </xsl:if>
         <xsl:apply-templates/>
      </itemizedlist>
   </xsl:template>
   
   <xsl:template match="table[@*]">
      <table>
         <xsl:copy-of
            select="@*[name() != 'pgwide' and 
                       name() != 'frame']"/>
         <xsl:if test="@frame != 'topbot'">
            <xsl:attribute name="frame">
               <xsl:value-of select="@frame"/>
            </xsl:attribute>
         </xsl:if>
         <xsl:if test="@pgwide != '0'">
            <xsl:attribute name="pgwide">
               <xsl:value-of select="@pgwide"/>
            </xsl:attribute>
         </xsl:if>
         <xsl:apply-templates/>
      </table>
   </xsl:template>
   
   <xsl:template match="sect1[@role='General']">
      <sect1>
         <xsl:copy-of select="@*[ name() != 'role' ]"/>
         <xsl:apply-templates/>
      </sect1>
   </xsl:template>
   
   <xsl:template match="step[@performance='required']">
      <step>
         <xsl:copy-of select="@*[name() != 'performance']"/>
         <xsl:apply-templates/>
      </step>
   </xsl:template>
   
   <xsl:template match="xref[@xrefstyle='HeadingOnPage' or 
                             @xrefstyle='SectTitleOnPage']">
      <xref>
         <xsl:copy-of select="@*[name() != 'xrefstyle']"/>
      </xref>
   </xsl:template>

</xsl:stylesheet>
