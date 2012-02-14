<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet 
[
  <!ENTITY % fontsizes SYSTEM "fontsizes.ent">
  %fontsizes;
]>
<xsl:stylesheet version="1.0"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="book.titlepage.recto">
  <xsl:variable name="textwidth">
    <!--<xsl:value-of select="$page.width"/>
    <xsl:text> - </xsl:text>
    <xsl:value-of select="$page.margin.inner"/>
    <xsl:text> - </xsl:text>
    <xsl:value-of select="$page.margin.outer"/>-->
    103.5mm
  </xsl:variable>
  <xsl:variable name="picture.with">70pt</xsl:variable>
  
  <fo:block margin-top="10em" hyphenate="false" text-align="center">
    <fo:block id="book.productname.__1"
      font-weight="400"
      font-size="&huge;"
      space-after=".5em"
      font-family="{$title.fontset}">
      <xsl:apply-templates select="self::book/bookinfo/productname"/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="self::book/bookinfo/productnumber" />
    </fo:block>
    <!--<fo:leader leader-length="{$picture.with}" leader-pattern="rule" leader-pattern-width="0.8pt"/>-->
    <fo:block id="book.title.__1"
      space-before=".5em"
      space-after=".5em"
      font-size="&Huge;"
      font-weight="400"
      font-family="{$title.fontset}">
        <xsl:choose>
          <!-- FIXME: What about very long titles?
               Use different, possible titles
             -->
          <xsl:when test="bookinfo/title">
            <xsl:apply-templates mode="book.titlepage.recto.auto.mode"
              select="bookinfo/title"/>
          </xsl:when>
          <xsl:when test="bookinfo/titleabbrev">
            <xsl:apply-templates select="bookinfo/titleabbrev"/>
          </xsl:when>
          <xsl:when test="bookinfo/invpartnumber">
            <xsl:apply-templates select="bookinfo/invpartnumber"/>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
        
        <xsl:choose>
         <xsl:when test="bookinfo/date">
          <xsl:apply-templates select="bookinfo/date" mode="book.titlepage.recto.auto.mode"/>
         </xsl:when>
        </xsl:choose>
     
    </fo:block>
    <!--<fo:leader leader-length="{$picture.with}" leader-pattern="rule" leader-pattern-width="0.8pt"/>-->
  </fo:block>
  
  <!-- left: 202pt -->
  <fo:block-container top="{$page.height} -94.5pt -5pt"
   left="({$page.width} - {$picture.with}) div 2"
   right="63pt"
   bottom="40.5pt"
   absolute-position="fixed">
   <fo:block><fo:external-graphic
           content-width="{$picture.with}" width="{$picture.with}">
     <xsl:attribute name="src">
       <xsl:choose>
         <xsl:when test="$format.print = '1'">
           <xsl:call-template name="fo-external-image">
             <xsl:with-param name="filename">
               <xsl:value-of select="$booktitlepage.bw.logo"/>
             </xsl:with-param>
           </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
           <xsl:call-template name="fo-external-image">
             <xsl:with-param name="filename">
               <xsl:value-of select="$booktitlepage.color.logo"/>
             </xsl:with-param>
           </xsl:call-template>
         </xsl:otherwise>
       </xsl:choose>
     </xsl:attribute>
    </fo:external-graphic>
   </fo:block>
  </fo:block-container>
</xsl:template>

<xsl:template match="bookinfo/title" mode="book.titlepage.verso.auto.mode">
  <fo:block xsl:use-attribute-sets="book.titlepage.verso.style">
    <xsl:call-template name="book.verso.title"/>
  </fo:block>
</xsl:template>


<xsl:template match="bookinfo/date" mode="book.titlepage.recto.auto.mode">
 <fo:block font-size="{1.2*$body.font.master}pt" space-before="2em">
   <xsl:apply-templates select="node()"/>
 </fo:block>
</xsl:template>

</xsl:stylesheet>
