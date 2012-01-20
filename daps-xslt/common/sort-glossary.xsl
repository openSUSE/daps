<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- $Id$ -->
<!DOCTYPE xsl:stylesheet
[
 <!ENTITY lowercase "'abcdefghijklmnopqrstuvwxyz'">
 <!ENTITY uppercase "'ABCDEFGHIJKLMNOPQRSTUVWXYZ'">

 <!ENTITY glossterm 'normalize-space(glossterm)'>


]>

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:exslt="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    xmlns:i="urn:cz-kosek:functions:index"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    extension-element-prefixes="func exslt"
    exclude-result-prefixes="func exslt i l"

>

<!--
  This stylesheets sorts a glossary from DocBook XML
-->

<xsl:output
   encoding="UTF-8"
   doctype-public="-//Novell//DTD NovDoc XML V1.0//EN"
   doctype-system="novdocx.dtd"
   method="xml"
   indent="yes"
   />


<xsl:param name="debug" select="1"/>
<xsl:param name="generate.glossary" select="1"/>
<xsl:param name="make.glossary.markup" select="0"/>


<xsl:key name="letter"
         match="glossentry"
         use="translate(substring(&glossterm;, 1, 1),&lowercase;,&uppercase;)"/>

<xsl:key name="glossentry"
         match="glossentry"
         use="&glossterm;"/>



<!-- Maybe already defined? -->
<xsl:variable name="ucletters"
     select="&uppercase;"/>
<xsl:variable name="lcletters"
     select="&lowercase;"/>



<xsl:template name="generate-glossary">

  <xsl:variable name="terms"
                select="//glossentry[count(.|key('letter',
                                                translate(substring(&glossterm;, 1, 1),
                                                          &lowercase;,
                                                          &uppercase;)))]"/>
  <xsl:variable name="alphabetical"
                select="$terms[contains(concat(&lowercase;, &uppercase;),
                                        substring(&glossterm;, 1, 1))]"/>

  <xsl:variable name="others" select="$terms[not(contains(concat(&lowercase;,
                                                 &uppercase;),
                                             substring(&glossterm;, 1, 1)))]"/>


  <xsl:variable name="ge" select="//glossentry[key('glossentry',  &glossterm;)]"/>

   <xsl:message> generate-glossary
   count(//glossentry) = <xsl:value-of select="count(//glossentry)"/>
   <!--terms        = <xsl:value-of select="count($terms)"/>-->
   ge           = <xsl:value-of select="count($ge)"/>
   <!--alphabetical = <xsl:value-of select="$alphabetical"/>-->
   </xsl:message>
</xsl:template>


<xsl:template name="generate-glossary-markup">
   <xsl:message> generate-glossary-markup </xsl:message>
</xsl:template>


<xsl:template match="/">
   <xsl:message>Sorting in progress ...</xsl:message>
   <xsl:apply-templates/>
</xsl:template>


<xsl:template match="glossary">
  <xsl:variable name="id">
<!--     <xsl:call-template name="object.id"/> -->
  </xsl:variable>

 <xsl:if test="$generate.glossary != 0">
  <xsl:choose>
    <xsl:when test="$make.glossary.markup != 0">
      <fo:block>
        <xsl:call-template name="generate-glossary-markup">
          <xsl:with-param name="scope" select="(ancestor::book|/)[last()]"/>
        </xsl:call-template>
      </fo:block>
    </xsl:when>
    <xsl:otherwise>
      <!--<fo:block id="{$id}">
        <xsl:call-template name="glossary.titlepage"/>
      </fo:block>-->
      <xsl:apply-templates/>
      <!--<xsl:if test="count(indexentry) = 0 and count(indexdiv) = 0">-->
        <xsl:call-template name="generate-glossary">
          <xsl:with-param name="scope" select="(ancestor::book|/)[last()]"/>
        </xsl:call-template>
      <!--</xsl:if>-->
    </xsl:otherwise>
  </xsl:choose>
 </xsl:if>
</xsl:template>


<!-- -->
<!-- Returns index group code for given term  -->
<!--<func:function name="i:group-index">
  <xsl:param name="term"/>

  <xsl:variable name="letters-rtf">
    <xsl:variable name="lang">
      <xsl:call-template name="l10n.language"/>
    </xsl:variable>

    <xsl:variable name="local.l10n.letters"
      select="($local.l10n.xml//l:i18n/l:l10n[@language=$lang]/l:letters)[1]"/>

    <xsl:variable name="l10n.letters"
      select="($l10n.xml/l:i18n/l:l10n[@language=$lang]/l:letters)[1]"/>

    <xsl:choose>
      <xsl:when test="count($local.l10n.letters) &gt; 0">
        <xsl:copy-of select="$local.l10n.letters"/>
      </xsl:when>
      <xsl:when test="count($l10n.letters) &gt; 0">
        <xsl:copy-of select="$l10n.letters"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>No "</xsl:text>
          <xsl:value-of select="$lang"/>
          <xsl:text>" localization of index grouping letters exists</xsl:text>
          <xsl:choose>
            <xsl:when test="$lang = 'en'">
              <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>; using "en".</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:message>

        <xsl:copy-of select="($l10n.xml/l:i18n/l:l10n[@language='en']/l:letters)[1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="long-letter-index"
                select="$letters/l:l[. = substring($term,1,2)]/@i"/>
  <xsl:variable name="short-letter-index"
                select="$letters/l:l[. = substring($term,1,1)]/@i"/>
  <xsl:variable name="letter-index">
    <xsl:choose>
      <xsl:when test="$long-letter-index">
        <xsl:value-of select="$long-letter-index"/>
      </xsl:when>
      <xsl:when test="$short-letter-index">
        <xsl:value-of select="$short-letter-index"/>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <func:result select="number($letter-index)"/>
</func:function>
-->


<!--<xsl:template match="@* | node() ">
   <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
   </xsl:copy>
</xsl:template>-->



<!--<xsl:template match="glossary">

   <glossary>
     <xsl:copy-of select="@*|processing-instruction()"/>
     <xsl:copy-of select="*[not(glossentry)]"/>
     <xsl:for-each select="glossentry">
       <xsl:sort select="translate(glossterm, $lcletters, $ucletters)" data-type="text" />
       <xsl:message>glossterm[<xsl:value-of
                  select="position()"/>] &quot;<xsl:value-of
                  select="translate(normalize-space(glossterm),
                     $lcletters, $ucletters)"/>&quot;</xsl:message>
     </xsl:for-each>
   </glossary>
   <xsl:text>&#10;</xsl:text>
</xsl:template>


<xsl:template match="glossentry">
  <glossentry>
    <xsl:copy-of select="@*|current()/node()"/>
  </glossentry>
</xsl:template>-->


<!--<xsl:template match="glossterm">
   <glossterm>
    <xsl:copy-of select="@*"/>
    <xsl:value-of select="normalize-space(.)"/>
   </glossterm>
</xsl:template>-->




</xsl:stylesheet>
