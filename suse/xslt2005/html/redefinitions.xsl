<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- $Id: redefinitions.xsl 43118 2009-07-14 14:12:30Z toms $ -->
<xsl:stylesheet
    version="1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    exclude-result-prefixes="l">


<!-- Other templates -->
<xsl:template match="authorgroup" mode="titlepage.mode">
  <table width="100%" xmlns="http://www.w3.org/1999/xhtml" class="{name(.)}">
   <tbody>
    <tr valign="top">
     <td width="15%">
     <xsl:choose>
       <xsl:when test="@role='authors'">
        <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="'Authors'"/>
        </xsl:call-template>
       </xsl:when>
       <xsl:when test="@role='office'">
        <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="'Office'"/>
        </xsl:call-template>
       </xsl:when>
       <xsl:when test="@role='translators'">
      <!--<xsl:if test="not(/book/@lang='en')">
         <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="'Translators'"/>
         </xsl:call-template>
      </xsl:if>-->
       </xsl:when>
       <xsl:otherwise>
        <!-- needs to be checked -->
        <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="'Authors'"/>
        </xsl:call-template>
       </xsl:otherwise>
     </xsl:choose>
    </td>
    <xsl:if test="not(@role='translators' and /book/@lang='de')">
     <td><xsl:apply-templates mode="titlepage.mode"/></td>
   </xsl:if>
    </tr>
   </tbody>
  </table>
</xsl:template>


<xsl:template match="author|othercredit" mode="titlepage.mode">
   <span class="{name(.)}">
      <xsl:call-template name="person.name"/>
      <xsl:apply-templates mode="titlepage.mode" select="./contrib"/>
      <xsl:apply-templates mode="titlepage.mode" select="./affiliation"/>
        <xsl:if test="count(following-sibling::author)>0 or
                      count(following-sibling::othercredit)>0">
         <xsl:text>, </xsl:text>
      </xsl:if>
   </span>
</xsl:template>


<xsl:template match="authorgroup[@role='translators']/author" mode="titlepage.mode">
   <span class="{name(.)}">
      <xsl:call-template name="person.name"/>
      <xsl:if test="count(following-sibling::author)>0">
            <xsl:if test="string-length(following-sibling::author/firstname)>0">
            <xsl:text>, </xsl:text>
         </xsl:if>
      </xsl:if>
   </span>
</xsl:template>

<!-- productname is now the title of the book -->

<!--
Display product name & version number for the book.titlepage.recto.auto.mode
(this mode is used by default, see suse-titlepage.xsl)
-->
 
<xsl:template match="bookinfo/productname" mode="book.titlepage.recto.auto.mode">
   <div>
      <h1 class="productname">
         <xsl:apply-templates/>
         <xsl:text> </xsl:text>
         <xsl:apply-templates select="../productnumber"/> 
      </h1>
   </div>
</xsl:template>
 
<!-- fallback -->

 <xsl:template match="bookinfo/productname" mode="titlepage.mode">
   <div>
      <h1 class="productname">
         <xsl:apply-templates/>
      </h1>
   </div>
</xsl:template>


<!-- titleabbrev is now the subtitle of the book -->
<xsl:template match="bookinfo/titleabbrev" mode="titlepage.mode">
   <div>
      <h2 class="subtitle">
         <xsl:apply-templates/>
      </h2>
   </div>
</xsl:template>


<xsl:template match="bookinfo/title/emphasis">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template name="xml.base.dirs">
   <!-- Empty, because we don't want that our graphics
        path are influenced by xml:base attributes
    -->
</xsl:template>

<!--<xsl:template match="*" mode="admon.graphic.width">
  <xsl:param name="node" select="."/>
  <xsl:text>0</xsl:text>
</xsl:template>-->

</xsl:stylesheet>
