<?xml version="1.0" encoding="UTF-8"?>
<!--
   Extract meta data for Docserv processing

  Purpose:
     This is the stylesheet that makes the "daps meta" command work

  Input:
     DocBook 5 document

  Output:
     Plain text with key=value lines

  Parameters:
     * "sep": Separation character of different items
     * "sep-entries": The separation character between different entries in a list
     * "with-warn": should warnings be printed? true()=yes, false()=no

  References:
     * Adding metadata to all SUSE documentation
       https://confluence.suse.com/x/f4GZW

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl">

  <xsl:output method="text"/>
  <xsl:strip-space elements="*"/>


  <!-- ===== Parameter -->
  <xsl:param name="sep-entries">;</xsl:param>
  <xsl:param name="sep">
    <xsl:text>&#10;</xsl:text>
  </xsl:param>
  <xsl:param name="with-warn" select="true()"/>
  <xsl:param name="version">1.0</xsl:param>

  <!-- ===== Helper templates -->
  <xsl:template name="warn">
    <xsl:param name="msg">Missing element</xsl:param>
    <xsl:param name="element"></xsl:param>
    <xsl:if test="boolean($with-warn)">
      <xsl:message>WARNING: <xsl:value-of select="concat($msg, ': ', $element)"/></xsl:message>
    </xsl:if>
  </xsl:template>


  <!-- ===== Empty templates -->
  <xsl:template match="d:appendix|d:article/*[not(self::d:info)]|
                       d:bibliography|d:colophon|
                       d:chapter|d:chapter/*[not(self::d:info)]|
                       d:dedication|
                       d:glossary|d:glossary/*[not(self::d:info)]|
                       d:module|
                       d:part|d:part/*[not(self::d:info)]|
                       d:preface|d:preface/*[not(self::d:info)]|
                       d:section|d:section/*[not(self::d:info)]|
                       d:sect1|d:sect1/*[not(self::d:info)]|
                       d:topic|d:topic/*[not(self::d:info)]|
                       d:title|d:subtitle"/>


  <!-- ===== info and merge  -->
  <xsl:template match="d:info|d:structure/d:merge">
    <xsl:text># Metadata output from v</xsl:text>
    <xsl:value-of select="concat($version, $sep)"/>
    <xsl:call-template name="product" />
    <xsl:call-template name="title" />
    <xsl:call-template name="subtitle" />
    <xsl:call-template name="seo-title" />
    <xsl:call-template name="seo-description" />
    <xsl:call-template name="seo-social-descr" />
    <xsl:call-template name="date" />
    <xsl:call-template name="task" />
    <xsl:call-template name="series" />
    <xsl:call-template name="category" />
    <xsl:call-template name="type" />
  </xsl:template>

  <xsl:template name="product">
    <xsl:param name="node" select="." />
    <xsl:choose>
      <xsl:when test="$node/d:meta[@name = 'productname']">
        <xsl:call-template name="meta-productname">
          <xsl:with-param name="meta" select="$node/d:meta[@name='productname']" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$node/d:productname">
        <xsl:variable name="meta-node">
          <d:meta name="productname">
            <d:productname
              version="{normalize-space(string($node/d:productnumber//*))}"
              os="{($node/d:productname//*/@os)[last()]}">
              <xsl:value-of select="normalize-space(string($node/d:productname))" />
            </d:productname>
          </d:meta>
        </xsl:variable>
        <!--<xsl:message>productnumber=<xsl:value-of select="string($node/d:productnumber//*)"/></xsl:message>-->
        <xsl:call-template name="meta-productname">
          <xsl:with-param name="meta" select="exsl:node-set($meta-node)/*" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise />
    </xsl:choose>
  </xsl:template>

  <xsl:template name="meta-productname">
    <xsl:param name="meta"/>
    <xsl:for-each select="$meta/*">
      <xsl:text>productname=</xsl:text>
      <!-- Add os and version information before product name -->
      <xsl:text>[</xsl:text>
      <xsl:if test="./@os"><xsl:value-of select="concat(./@os, $sep-entries)"/></xsl:if>
      <xsl:if test="./@version"><xsl:value-of select="./@version"/></xsl:if>
      <xsl:text>]</xsl:text>
      <xsl:value-of select="concat(string(current()), $sep)" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="title">
    <xsl:param name="node" select="." />
    <xsl:variable name="this-title">
      <xsl:choose>
        <xsl:when test="$node/d:title">
          <xsl:value-of select="string($node/d:title)"/>
        </xsl:when>
        <xsl:when test="$node/parent::*/d:title">
          <xsl:value-of select="string($node/parent::*/d:title)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$this-title != ''">
        <xsl:text>title=</xsl:text>
        <xsl:value-of select="concat(normalize-space($this-title), $sep)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>WARNING: No title could be found! :-(</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="subtitle">
    <xsl:param name="node" select="." />
    <xsl:variable name="this-subtitle">
      <xsl:choose>
        <xsl:when test="$node/d:subtitle">
          <xsl:value-of select="string($node/d:subtitle)"/>
        </xsl:when>
        <xsl:when test="$node/parent::*/d:subtitle">
          <xsl:value-of select="string($node/parent::*/d:subtitle)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$this-subtitle != ''">
        <xsl:text>subtitle=</xsl:text>
        <xsl:value-of select="concat(normalize-space($this-subtitle), $sep)"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="seo-title">
    <xsl:param name="node" select="." />
    <xsl:variable name="this-seo-title">
      <xsl:choose>
        <xsl:when test="$node/d:meta[@name='title']">
          <xsl:value-of select="string($node/d:meta[@name='title'])"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$this-seo-title != ''">
        <xsl:text>seo-title=</xsl:text>
        <xsl:value-of select="concat(normalize-space($this-seo-title), $sep)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warn">
          <xsl:with-param name="element">meta[@name='title']</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="seo-description">
    <xsl:param name="node" select="." />
    <xsl:variable name="this-seo-description">
      <xsl:choose>
        <xsl:when test="$node/d:meta[@name='description']">
          <xsl:value-of select="string($node/d:meta[@name='description'])"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$this-seo-description != ''">
        <xsl:text>seo-description=</xsl:text>
        <xsl:value-of select="concat(normalize-space($this-seo-description), $sep)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warn">
          <xsl:with-param name="element">meta[@name='description']</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="seo-social-descr">
    <xsl:param name="node" select="." />
    <xsl:variable name="this-seo-social-descr">
      <xsl:choose>
        <xsl:when test="$node/d:meta[@name='social-descr']">
          <xsl:value-of select="string($node/d:meta[@name='social-descr'])"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$this-seo-social-descr != ''">
        <xsl:text>seo-social-descr=</xsl:text>
        <xsl:value-of select="concat(normalize-space($this-seo-social-descr), $sep)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warn">
          <xsl:with-param name="element">meta[@name='social-descr']</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="date">
    <xsl:param name="node" select="." />
    <xsl:variable name="this-date">
      <xsl:choose>
        <xsl:when test="$node/d:revhistory/d:revision[1]/d:date">
          <xsl:value-of select="string($node/d:revhistory/d:revision[1]/d:date)"/>
        </xsl:when>
        <xsl:otherwise />
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$this-date != ''">
        <xsl:text>date=</xsl:text>
        <xsl:value-of select="concat(normalize-space($this-date), $sep)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warn">
          <xsl:with-param name="element">revhistory/revision/date</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="task">
    <xsl:param name="node" select="." />
    <xsl:variable name="this-task">
      <xsl:choose>
        <xsl:when test="$node/d:meta[@name='task']">
          <xsl:for-each select="$node/d:meta[@name='task']/d:*">
            <xsl:value-of select="string(.)"/>
            <xsl:if test="position() &lt; last()">
              <xsl:value-of select="$sep-entries"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$this-task != ''">
        <xsl:text>task=</xsl:text>
        <xsl:value-of select="concat(normalize-space($this-task), $sep)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warn">
          <xsl:with-param name="element">meta[@name='task']</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="series">
    <xsl:param name="node" select="." />
    <xsl:variable name="this-series">
      <xsl:choose>
        <xsl:when test="$node/d:meta[@name='series']">
          <xsl:value-of select="string($node/d:meta[@name='series'])"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$this-series != ''">
        <xsl:text>series=</xsl:text>
        <xsl:value-of select="concat(normalize-space($this-series), $sep)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warn">
          <xsl:with-param name="element">meta[@name='series']</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="category">
    <xsl:param name="node" select="." />
    <xsl:variable name="this-category">
      <xsl:choose>
        <xsl:when test="$node/d:meta[@name='category']">
          <xsl:for-each select="$node/d:meta[@name='category']/d:*">
            <xsl:value-of select="string(.)"/>
            <xsl:if test="position() &lt; last()">
              <xsl:value-of select="$sep-entries"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$this-category != ''">
        <xsl:text>category=</xsl:text>
        <xsl:value-of select="concat(normalize-space($this-category), $sep)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warn">
          <xsl:with-param name="element">meta[@name='category']</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="type">
    <xsl:param name="node" select="." />
    <xsl:variable name="this-type">
      <xsl:choose>
        <xsl:when test="$node/d:meta[@name='type']">
          <xsl:value-of select="string($node/d:meta[@name='type'])"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$this-type != ''">
        <xsl:text>type=</xsl:text>
        <xsl:value-of select="concat(normalize-space($this-type), $sep)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warn">
          <xsl:with-param name="element">meta[@name='type']</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
