<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY db "http://docbook.sourceforge.net/release/xsl/current/">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes" />

    <xsl:param name="rootid" />
    <xsl:param name="term.separator">, </xsl:param>

    <xsl:template match="text()" />

    <xsl:key name="id" match="*" use="@id|@xml:id" />
    <xsl:key name="primary" match="indexterm" 
        use="normalize-space(concat(primary/@sortas, primary[not(@sortas)]))" />


    <xsl:template match="/">
        <xsl:param name="rootidname" select="name(key('id', $rootid))" />
        <xsl:param name="rootidnode" select="(key('id', $rootid)|/)[last()]" />

       <!--<xsl:message>xml2idx.xsl: Rootid is '<xsl:value-of 
         select="$rootid"/>'|'<xsl:value-of select="$rootidname"/>'</xsl:message>
-->
        <index>
            <title>
                <xsl:value-of select="($rootidnode/article/index/title |
                                                    $rootidnode/book/index/title)[last()]"/>
            </title>
            <xsl:choose>
                <xsl:when test="$rootid != ''">
                    <xsl:apply-templates select="key('id', $rootid)" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </index>
    </xsl:template>


    <xsl:template match="indexterm/primary[. = '']">
        <xsl:message> Warning: Empty indexterm/primary...</xsl:message>
    </xsl:template>

    <xsl:template match="indexterm[not(@class='endofrange')]">
        <indexentry>
          <xsl:variable name="key">
              <!-- Should there be a better attribute name?
                key is not allowed in indexentry, role is a bit too
                generic
              -->
              <xsl:value-of select="primary"/>
              <xsl:if test="secondary">
                <xsl:value-of select="concat($term.separator, secondary)"/>
                <xsl:if test="tertiary">
                  <xsl:value-of select="concat($term.separator, tertiary)"/>
                </xsl:if>
              </xsl:if>
          </xsl:variable>
            
            <xsl:apply-templates>
              <xsl:with-param name="pos">
                 <xsl:number count="indexterm" level="any" />
              </xsl:with-param>
              <xsl:with-param name="key" select="$key"/>
            </xsl:apply-templates>
        </indexentry>
    </xsl:template>

    <xsl:template match="primary|secondary|tertiary">
      <xsl:param name="pos"/>
      <xsl:param name="key"/>
        
        <xsl:element name="{name()}ie">
            <xsl:if test="@sortas">
                <phrase role="sortas">
                    <xsl:value-of select="@sortas" />
                </phrase>
            </xsl:if>
            <xsl:if test="not(following-sibling::*[not(see) or not(seealso) ])">
              <phrase role="key">
                <xsl:value-of select="$key"/>
              </phrase>            
            </xsl:if>
            <phrase>
              <xsl:value-of select="." />
            </phrase>
        </xsl:element>
    </xsl:template>

    <xsl:template match="see|seealso">
        <xsl:message>  xml2idx: '<xsl:value-of select="name()"/>'</xsl:message>
        <xsl:element name="{name()}ie">
             <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    

</xsl:stylesheet>
