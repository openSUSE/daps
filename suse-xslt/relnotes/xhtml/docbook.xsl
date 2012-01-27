<xsl:stylesheet version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl"/> -->
  <xsl:import href="file:///usr/share/xml/docbook/stylesheet/nwalsh/current/xhtml/docbook.xsl"/>
  
  <!-- Enable Section numbering -->
  <xsl:param name="section.autolabel" select="1"/>
  <xsl:param name="section.label.includes.component.label" select="1"/>
   <!-- Show links? -->
  <xsl:param name="ulink.show" select="0"/>
 
  
  <!-- Suppress sections with role='notoc' -->
  <xsl:template match="section[@role='notoc']" mode="toc"/>
  
  <!-- Make all section titles with role='nonumber' -->
  <xsl:template match="section/title[@role='nonumber']" mode="titlepage.mode">
    <xsl:variable name="section" 
                select="(ancestor::section |
                        ancestor::simplesect |
                        ancestor::sect1 |
                        ancestor::sect2 |
                        ancestor::sect3 |
                        ancestor::sect4 |
                        ancestor::sect5)[position() = last()]"/>

  <div>
    <xsl:variable name="id">
      <xsl:call-template name="object.id">
        <xsl:with-param name="object" select="$section"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="renderas">
      <xsl:choose>
        <xsl:when test="$section/@renderas = 'sect1'">1</xsl:when>
        <xsl:when test="$section/@renderas = 'sect2'">2</xsl:when>
        <xsl:when test="$section/@renderas = 'sect3'">3</xsl:when>
        <xsl:when test="$section/@renderas = 'sect4'">4</xsl:when>
        <xsl:when test="$section/@renderas = 'sect5'">5</xsl:when>
        <xsl:otherwise><xsl:value-of select="''"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="level">
      <xsl:choose>
        <xsl:when test="$renderas != ''">
          <xsl:value-of select="$renderas"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="section.level">
            <xsl:with-param name="node" select="$section"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="marker">
      <xsl:choose>
        <xsl:when test="$level &lt;= $marker.section.level">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:apply-templates />
      <!--
        <xsl:apply-templates select="$section" mode="object.title.markup.textonly">
        <xsl:with-param name="allow-anchors" select="1"/>
      </xsl:apply-templates>
      -->
    </xsl:variable>
    <xsl:variable name="marker.title">
      <xsl:apply-templates select="$section" mode="titleabbrev.markup">
        <xsl:with-param name="allow-anchors" select="0"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:call-template name="section.heading">
      <xsl:with-param name="level" select="$level"/>
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="marker" select="$marker"/>
      <xsl:with-param name="marker.title" select="$marker.title"/>
    </xsl:call-template>
  </div>
  </xsl:template>


</xsl:stylesheet>
