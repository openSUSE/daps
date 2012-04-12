<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:fo="http://www.w3.org/1999/XSL/Format">


   <xsl:template name="addstatus">
      <xsl:param name="node" select="."/>
      
      <xsl:if test="($draft.mode = 'yes' or $draft.mode = 'maybe') and
         $node/@status">
         <fo:inline xsl:use-attribute-sets="status.inline.properties">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="$node/@status"/>
            <xsl:text>]</xsl:text>
         </fo:inline>
      </xsl:if>
   </xsl:template>
   
   
   <xsl:template name="section.heading">
      <xsl:param name="level" select="1"/>
      <xsl:param name="marker" select="1"/>
      <xsl:param name="title"/>
      <xsl:param name="titleabbrev"/>
      
      <xsl:variable name="_label">
         <xsl:variable name="tmplabel">
            <xsl:apply-templates select="parent::*[1]" mode="label.markup"/>
         </xsl:variable>
         <xsl:if test="not(self::bridgehead)">
            <xsl:choose>
               <xsl:when test="$tmplabel != ''">
                  <xsl:copy-of select="$tmplabel"/>
                  <!-- Integrate a dot after the label? -->
                  <xsl:call-template name="gentext.template">
                     <xsl:with-param name="name" select="'dot.after.section'"/>
                     <xsl:with-param name="context" select="'parameters'"/>
                  </xsl:call-template>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:copy-of select="$tmplabel"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:if>
      </xsl:variable>
      
      <xsl:variable name="_title">
         <xsl:apply-templates select="node()"  mode="title.markup"/>
         <xsl:call-template name="addstatus">
            <xsl:with-param name="node" select=".."/>
         </xsl:call-template>
      </xsl:variable>
      
      <xsl:variable name="head.marker">
         <xsl:if test="$marker != 0">
            <fo:marker marker-class-name="section.head.marker">
               <xsl:choose>
                  <xsl:when test="$titleabbrev = ''">
                     <xsl:value-of select="$title"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="$titleabbrev"/>
                  </xsl:otherwise>
               </xsl:choose>
            </fo:marker>
         </xsl:if>
      </xsl:variable>
      
      
      <!--<xsl:message> section.heading
   Label: "<xsl:value-of select="$_label"/>"-
          "<xsl:value-of select="$_label=1"/>"-
          "<xsl:value-of select="$_label='1'"/>"
   Titel: <xsl:value-of select="$_title"/>
  </xsl:message>-->
      
      
      <xsl:variable name="floatblock">
         <xsl:choose>
            <xsl:when test="$_label=''">
               <fo:block>
                  <xsl:copy-of select="$_title"/>
               </fo:block>
            </xsl:when>
            <xsl:otherwise>
               <xsl:choose>
                  <xsl:when test="$xep.extensions != 0">
                     <fo:block>
                        <fo:float float="start">
                           <fo:block margin-right="0.5em">
                              <xsl:copy-of select="$_label"/>
                           </fo:block>
                        </fo:float>
                        <fo:float intrusion-displace="block">
                           <fo:block>
                              <xsl:copy-of select="$_title"/>
                           </fo:block>
                        </fo:float>
                     </fo:block>
                  </xsl:when>
                  <xsl:otherwise>
                     <fo:block>
                        <xsl:copy-of select="$_label"/>
                        <xsl:text> </xsl:text>
                        <xsl:copy-of select="$_title"/>
                     </fo:block>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <xsl:choose>
         <xsl:when test="$level='1'">
            <fo:block
               xsl:use-attribute-sets="section.title.properties
               section.title.level1.properties">
               <xsl:copy-of select="$floatblock"/>
            </fo:block>
         </xsl:when>
         <xsl:when test="$level='2'">
            <fo:block
               xsl:use-attribute-sets="section.title.properties
               section.title.level2.properties">
               <xsl:copy-of select="$floatblock"/>
            </fo:block>
         </xsl:when>
         <xsl:when test="$level='3'">
            <fo:block
               xsl:use-attribute-sets="section.title.properties
               section.title.level3.properties">
               <xsl:copy-of select="$floatblock"/>
            </fo:block>
         </xsl:when>
         <xsl:when test="$level='4'">
            <fo:block
               xsl:use-attribute-sets="section.title.properties
               section.title.level4.properties">
               <xsl:copy-of select="$floatblock"/>
            </fo:block>
         </xsl:when>
         <xsl:when test="$level='5'">
            <fo:block
               xsl:use-attribute-sets="section.title.properties
               section.title.level5.properties">
               <xsl:copy-of select="$floatblock"/>
            </fo:block>
         </xsl:when>
         <xsl:otherwise>
            <fo:block>
               <xsl:copy-of select="$floatblock"/>
            </fo:block>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
</xsl:stylesheet>