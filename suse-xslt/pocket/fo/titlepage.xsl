<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet 
[
  <!ENTITY % fontsizes SYSTEM "fontsizes.ent">
  %fontsizes;
]>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">


<xsl:template name="chapappendix.title">
  <xsl:param name="node" select="."/>
  <xsl:variable name="nodepi" select="$node"/>
  <xsl:variable name="id">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$node"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="_label">
    <xsl:apply-templates select="$nodepi" mode="label.markup"/>
  </xsl:variable>
  <xsl:variable name="_title">
    <xsl:apply-templates select="$nodepi" mode="title.markup"/>
  </xsl:variable>
  
  <!--<xsl:message>chapappendix.title: <xsl:value-of select="name($node)"/>
  label: "<xsl:value-of select="string($_label)"/>"
  title: "<xsl:value-of select="string($_title)"/>"
  </xsl:message>-->
  
  <xsl:choose>
    <xsl:when test="$_label = ''">
      <!-- For example: preface, glossary, ... -->
      <fo:block color="orange" font-size="&LARGE;" hyphenate="false" vertical-align="text-bottom">
           <xsl:copy-of select="$_title"/>
      </fo:block>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$xep.extensions != 0">
          <fo:block space-before="5em" 
            space-before.conditionality="retain" 
            space-after="1.25em">
            <fo:float float="start">
              <fo:block margin-right="0.5em" font-weight="bold" font-size="&huge;" 
                vertical-align="text-bottom">
                <xsl:copy-of select="$_label"/>
              </fo:block>
            </fo:float>
            <fo:float intrusion-displace="block">
              <fo:block font-size="&LARGE;" hyphenate="false" vertical-align="text-bottom">
                <!-- A little hack to adjust the height -->
                <fo:inline font-weight="bold" font-size="&huge;" color="white"><fo:leader 
                  leader-length="0pt" leader-pattern="space"/></fo:inline>
                <xsl:copy-of select="$_title"/>
              </fo:block>
            </fo:float>
          </fo:block>
        </xsl:when>
        <xsl:otherwise>
          <fo:block space-before="3.5em" 
            space-before.conditionality="retain"
            space-after="1.25em">
            <xsl:apply-templates select="$nodepi" mode="label.markup"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="$nodepi" mode="title.markup"/>
          </fo:block>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
  
</xsl:template>


<xsl:template name="table.of.contents.titlepage.recto">
  <fo:block xsl:use-attribute-sets="table.of.contents.titlepage.recto.style" 
    space-before.minimum="1em" 
    space-before.optimum="1.5em" 
    space-before.maximum="2em"
    space-before.precedence="3"
    space-before.conditionality="retain"
    space-after="0.5em" 
    margin-left="{$title.margin.left}" 
    start-indent="0pt" font-size="&LARGE;" font-family="{$title.fontset}">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'TableofContents'"/>
      </xsl:call-template></fo:block>
</xsl:template>

<xsl:template match="title/emphasis">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="title" mode="part.titlepage.recto.auto.mode">
    <fo:block xsl:use-attribute-sets="part.titlepage.recto.style">
      <xsl:call-template name="division.title">
        <xsl:with-param name="node" select="ancestor-or-self::part[1]"/>
      </xsl:call-template>
    </fo:block>
</xsl:template>
  
<xsl:template name="article.titlepage.verso">
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="articleinfo/revhistory"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="artheader/revhistory"/>
  <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="info/revhistory"/>
</xsl:template>

<xsl:template match="subtitle[productname]" mode="article.titlepage.recto.auto.mode"/>

<xsl:template match="subtitle" mode="article.titlepage.recto.auto.mode">
  <fo:block xsl:use-attribute-sets="article.titlepage.recto.style" text-align="left">
     <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>

</xsl:stylesheet>
