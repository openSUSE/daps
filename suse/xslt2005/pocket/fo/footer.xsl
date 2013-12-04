<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: footer.xsl 5710 2006-02-08 13:52:33Z toms $ -->
<!DOCTYPE xsl:stylesheet >
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">


<!-- Just to change footer separator... -->
<xsl:template name="foot.sep.rule">
  <xsl:if test="$footer.rule != 0">
    <xsl:attribute name="border-top-width">thin</xsl:attribute>
    <xsl:attribute name="border-top-style">solid</xsl:attribute>
    <xsl:attribute name="border-top-color">silver</xsl:attribute>
  </xsl:if>
</xsl:template>


<xsl:template name="footer.content">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="position" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

<!--  <xsl:message>
  pageclass = <xsl:value-of select="$pageclass"/>
  sequence  = <xsl:value-of select="$sequence"/>
  position  = <xsl:value-of select="$position"/>
  gentext-key = <xsl:value-of select="$gentext-key"/>
  </xsl:message>-->

  <fo:block>
    <!-- pageclass can be front, body, back -->
    <!-- sequence can be odd, even, first, blank -->
    <!-- position can be left, center, right -->

   <!--<fo:table>-->
    <xsl:choose>
      <!--<xsl:when test="$position='left'">
        <xsl:attribute name="margin-left">-63pt</xsl:attribute>
      </xsl:when>-->
      <xsl:when test="$sequence='first' or $position='right'">
        <!--<xsl:attribute name="margin-right">-63pt</xsl:attribute>-->
        <xsl:attribute name="text-align">right</xsl:attribute>
      </xsl:when>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="$pageclass = 'lot'">
         <xsl:choose>
            <xsl:when test="local-name(.) = 'book'"/><!-- Do nothing -->
            <xsl:when test="$position='right' and
            ($sequence = 'first' or $sequence = 'odd')">
               <!-- TITEL PAGENUMBER -->
               <xsl:call-template name="footer.rightside"/>
            </xsl:when>
            <xsl:when test="$position='left' and $sequence = 'even'">
               <!-- PAGENUMBER TITEL -->
               <xsl:call-template name="footer.leftside"/>
            </xsl:when>
            <xsl:otherwise/><!-- Do nothing -->
         </xsl:choose>
      </xsl:when>

      <xsl:when test="$pageclass = 'front' or $pageclass = 'back'">
         <xsl:choose>
            <xsl:when test="$position='right' and
               ($sequence = 'first' or $sequence = 'odd')">
              <xsl:call-template name="footer.rightside"/>
            </xsl:when>
            <xsl:when test="$position='left' and $sequence = 'even'">
              <xsl:call-template name="footer.leftside"/>
            </xsl:when>
            <xsl:otherwise/><!-- Do nothing -->
         </xsl:choose>
      </xsl:when>

      <xsl:when test="$pageclass = 'body'">
         <xsl:choose>
            <xsl:when test="$sequence='first' and $gentext-key='article'"/>

            <xsl:when test="$position='' and $sequence='first'">
               <xsl:call-template name="footer.rightside"/>
            </xsl:when>

            <xsl:when test="$position='right' and $sequence = 'odd'">
               <xsl:call-template name="footer.rightside"/>
            </xsl:when>

            <xsl:when test="$position='left' and $sequence = 'even'">
               <xsl:call-template name="footer.leftside"/>
            </xsl:when>
            <xsl:otherwise/><!-- Do nothing -->
         </xsl:choose>
      </xsl:when>

      <!--
      <xsl:when test="$pageclass = 'titlepage'">
      </xsl:when>
      -->

      <xsl:otherwise/><!-- nop -->
    </xsl:choose>
 </fo:block>
</xsl:template>


<xsl:template name="footer.leftside">
   <xsl:param name="title">
     <xsl:choose>
       <xsl:when test="ancestor-or-self::book/bookinfo/title">
         <xsl:value-of select="ancestor-or-self::book/bookinfo/title"/>
       </xsl:when>
       <xsl:when test="ancestor-or-self::info/title">
         <xsl:value-of select="ancestor-or-self::book/info/title"/>
       </xsl:when>
       <xsl:when test="ancestor-or-self::book/title">
         <xsl:value-of select="ancestor-or-self::book/title"/>
       </xsl:when>
       <xsl:otherwise>
         <xsl:message>WARNING: No title found for verso footer</xsl:message>
       </xsl:otherwise>
     </xsl:choose>
   </xsl:param>

   <fo:inline font-family="{$sans.font.family}"
   font-weight="bold"><fo:page-number/></fo:inline>
   <fo:inline margin-left="17pt"
     font-family="{$sans.font.family}"
   ><xsl:value-of select="normalize-space($title)"/></fo:inline>
</xsl:template>

<xsl:template name="footer.rightside">
  <fo:inline text-align="right"
   margin-right="17pt"
   font-family="{$sans.font.family}"><xsl:value-of
   select="title"/></fo:inline>
  <fo:inline text-align="right"
   font-weight="bold"><fo:page-number/></fo:inline>
</xsl:template>



<xsl:template name="footer.table">
  <xsl:param name="pageclass" select="''"/>
  <xsl:param name="sequence" select="''"/>
  <xsl:param name="gentext-key" select="''"/>

<!--  <xsl:message>header.table:
   pageclass   = "<xsl:value-of select="$pageclass"/>"
   sequence    = "<xsl:value-of select="$sequence"/>"
   gentext-key = "<xsl:value-of select="$gentext-key"/>"
  </xsl:message>-->

  <!-- default is a single table style for all headers -->
  <!-- Customize it for different page classes or sequence location -->

  <xsl:choose>
      <xsl:when test="$pageclass = 'index'">
          <xsl:attribute name="margin-left">0pt</xsl:attribute>
      </xsl:when>
  </xsl:choose>

  <xsl:variable name="lefttoright">
      <xsl:choose>
         <xsl:when test="$sequence = 'even'">
            <xsl:text>left</xsl:text>
         </xsl:when>
         <xsl:when test="$sequence = 'odd'">
            <xsl:text>right</xsl:text>
         </xsl:when>
         <xsl:otherwise/>
      </xsl:choose>
  </xsl:variable>


  <xsl:variable name="candidate">
    <fo:table table-layout="fixed" width="100%"
              font-family="{$sans.font.family}">
      <xsl:call-template name="head.sep.rule">
        <xsl:with-param name="pageclass" select="$pageclass"/>
        <xsl:with-param name="sequence" select="$sequence"/>
        <xsl:with-param name="gentext-key" select="$gentext-key"/>
      </xsl:call-template>

      <fo:table-body>
        <fo:table-row height="14pt">
          <fo:table-cell text-align="left"
                         display-align="before"
                         ><!-- border="0.25pt blue solid"
                         padding-bottom="0.5pt" -->
            <xsl:if test="$fop.extensions = 0">
              <xsl:attribute name="relative-align">baseline</xsl:attribute>
            </xsl:if>
            <xsl:if test="$lefttoright != ''">
               <xsl:attribute name="text-align">
                  <xsl:value-of select="$lefttoright"/>
               </xsl:attribute>
            </xsl:if>
            <fo:block>
              <xsl:if test="$lefttoright">
               <xsl:call-template name="footer.content">
                  <xsl:with-param name="pageclass" select="$pageclass"/>
                  <xsl:with-param name="sequence" select="$sequence"/>
                  <xsl:with-param name="position" select="$lefttoright"/>
                  <xsl:with-param name="gentext-key" select="$gentext-key"/>
               </xsl:call-template>
              </xsl:if>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-body>
    </fo:table>
  </xsl:variable>

  <!-- Really output a header? -->
  <xsl:choose>
    <xsl:when test="$pageclass = 'titlepage' and $gentext-key = 'book'
                    and $sequence='first'">
      <!-- no, book titlepages have no footer at all -->
    </xsl:when>
    <xsl:when test="$sequence = 'blank' and $headers.on.blank.pages = 0">
      <!-- no output -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$candidate"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>