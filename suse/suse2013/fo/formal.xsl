<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Split formal titles into number and title

  Author(s):    Thomas Schraitle <toms@opensuse.org>,
                Stefan Knorr <sknorr@suse.de>

  Copyright:    2012, 2013, Thomas Schraitle, Stefan Knorr

-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  <!ENTITY % colors SYSTEM "colors.ent">
  <!ENTITY % metrics SYSTEM "metrics.ent">
  %fonts;
  %colors;
  %metrics;
]>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <!-- Hopefully, a future version of the DocBook stylesheets will feature a
       more
       stomachable version of this template, in which case we can simply move our
       modification to not use example.properties except when ...[FIXME] -->
  <xsl:template name="formal.object">
    <xsl:param name="placement" select="'before'"/>

    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>

    <xsl:variable name="content">
      <xsl:if test="$placement = 'before'">
        <xsl:call-template name="formal.object.heading">
          <xsl:with-param name="placement" select="$placement"/>
        </xsl:call-template>
      </xsl:if>
      <fo:block>
        <!-- The equivalent of div.complex-example in HTML-->
        <xsl:if test="self::example">
          <xsl:if test="glosslist|bibliolist|itemizedlist|orderedlist|
                        segmentedlist|simplelist|variablelist|programlistingco|
                        screenco|screenshot|cmdsynopsis|funcsynopsis|
                        classsynopsis|fieldsynopsis|constructorsynopsis|
                        destructorsynopsis|methodsynopsis|formalpara|para|
                        simpara|address|blockquote|graphicco|mediaobjectco|
                        indexterm|beginpage">
            <xsl:attribute name="border-{$start-border}"
              ><xsl:value-of select="&mediumline;"/>mm solid &light-gray;</xsl:attribute>
            <xsl:attribute name="margin-{$start-border}"
              ><xsl:value-of select="&mediumline; div 2"/>mm</xsl:attribute>
              <!-- This is seemingly illogical... but looks better with both FOP and
               XEP. -->
            <xsl:attribute name="padding-{$start-border}"
              ><xsl:value-of select="&columnfragment;"/>mm</xsl:attribute>
          </xsl:if>
        </xsl:if>
        <xsl:apply-templates/>
      </fo:block>
      <xsl:if test="$placement != 'before'">
        <xsl:call-template name="formal.object.heading">
          <xsl:with-param name="placement" select="$placement"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="keep.together">
      <xsl:call-template name="pi.dbfo_keep-together"/>
    </xsl:variable>

    <xsl:choose>
      <!-- tables have their own templates and
           are not handled by formal.object -->
      <xsl:when test="self::figure">
        <fo:block id="{$id}"
                  xsl:use-attribute-sets="figure.properties">
          <xsl:if test="$keep.together != ''">
            <xsl:attribute name="keep-together.within-column"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
          </xsl:if>
          <xsl:copy-of select="$content"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="self::example">
        <fo:block id="{$id}"
                  xsl:use-attribute-sets="example.properties">
          <xsl:if test="$keep.together != ''">
            <xsl:attribute name="keep-together.within-column"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
          </xsl:if>
          <xsl:copy-of select="$content"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="self::equation">
        <fo:block id="{$id}"
                  xsl:use-attribute-sets="equation.properties">
          <xsl:if test="$keep.together != ''">
            <xsl:attribute name="keep-together.within-column"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
          </xsl:if>
          <xsl:copy-of select="$content"/>
        </fo:block>
      </xsl:when>
      <xsl:when test="self::procedure">
        <fo:block id="{$id}"
                  xsl:use-attribute-sets="procedure.properties">
          <xsl:if test="$keep.together != ''">
            <xsl:attribute name="keep-together.within-column"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
          </xsl:if>
          <xsl:copy-of select="$content"/>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block id="{$id}"
                  xsl:use-attribute-sets="formal.object.properties">
          <xsl:if test="$keep.together != ''">
            <xsl:attribute name="keep-together.within-column"><xsl:value-of
                            select="$keep.together"/></xsl:attribute>
          </xsl:if>
          <xsl:copy-of select="$content"/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template
    match="procedure|example|table|figure|variablelist|itemizedlist|orderedlist"
    mode="object.label.template">
    <xsl:call-template name="gentext.template">
      <xsl:with-param name="context" select="'styles'"/>
      <xsl:with-param name="name" select="concat( local-name(),'-label')"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="procedure|example|table|figure|variablelist|itemizedlist|orderedlist"
    mode="object.title.template">
    <xsl:call-template name="gentext.template">
      <xsl:with-param name="context" select="'styles'"/>
      <xsl:with-param name="name" select="concat( local-name(),'-title')"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="formal.object.heading">
    <xsl:param name="object" select="."/>
    <xsl:param name="placement" select="'before'"/>
    <xsl:variable name="label.template">
      <xsl:apply-templates select="$object" mode="object.label.template"/>
    </xsl:variable>

    <fo:block xsl:use-attribute-sets="formal.title.properties"
      space-before="{&gutter;}mm" space-after="0em"
      line-height="{$base-lineheight * 0.85}em">
      <xsl:choose>
        <xsl:when test="$placement = 'before'">
          <xsl:attribute
            name="keep-with-next.within-column">always</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute
            name="keep-with-previous.within-column">always</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$label.template != ''">
        <fo:inline xsl:use-attribute-sets="title.number.color">
          <xsl:call-template name="substitute-markup">
            <xsl:with-param name="template" select="$label.template"/>
          </xsl:call-template>
          <xsl:text>&#xA0;</xsl:text>
        </fo:inline>
      </xsl:if>
      <fo:inline xsl:use-attribute-sets="title.name.color">
        <xsl:apply-templates select="$object" mode="title.markup">
          <xsl:with-param name="allow-anchors" select="1"/>
        </xsl:apply-templates>
        <xsl:text> </xsl:text>
      </fo:inline>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>
