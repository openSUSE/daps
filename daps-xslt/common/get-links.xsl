<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:output method="html"/>

  <xsl:key name="id" match="*" use="@id|@xml:id"/>
  
  <xsl:param name="nolocalhost" select="1"/>
  <xsl:param name="rootid"/>

  <xsl:template match="/">
    <html>
      <body>
        <xsl:choose>
          <xsl:when test="$rootid != ''">
            <h1>
              <xsl:text>Links for </xsl:text>
              <xsl:choose>
                <xsl:when test="key('id',$rootid)/@xml:base">
                  <xsl:value-of select="key('id',$rootid)/@xml:base"/>
                  <xsl:text> (id=</xsl:text>
                  <xsl:value-of select="$rootid"/>
                  <xsl:text>)</xsl:text>
                </xsl:when>
              </xsl:choose>
            </h1>
            <p>Total links: <xsl:value-of
                select="count(key('id',$rootid)//ulink)"/></p>
            <xsl:apply-templates select="key('id',$rootid)//ulink"/>
          </xsl:when>
          <xsl:otherwise>
            <h1>Links for Checkbot</h1>
            <p>Total links: <xsl:value-of select="count(.//ulink)"/></p>
            <br/>
            <xsl:apply-templates select=".//ulink"/>
          </xsl:otherwise>
        </xsl:choose>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="ulink">
    <xsl:for-each select="./@url">
      <xsl:choose>
        <xsl:when test="starts-with(., 'http://') or 
                        starts-with(., 'https://')">
          <xsl:choose>
            <xsl:when test="$nolocalhost != 0 and 
                            contains(., 'localhost')">
              <xsl:message>  Suppressing URL "<xsl:value-of
                select="."/>"</xsl:message>
            </xsl:when>
            <xsl:otherwise>
              <p>
                <a href="{.}">
                  <xsl:value-of select="."/>
                </a>
                <xsl:call-template name="getxmlbase"/>
              </p>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="starts-with(., 'ftp') or 
                        starts-with(., 'sftp')">
          <p>
            <a href="{.}">
              <xsl:value-of select="."/>
            </a>
            <xsl:call-template name="getxmlbase"/>
          </p>
        </xsl:when>
        <xsl:when test="starts-with(., 'mailto')">
          <!--<p>Test this mailto reference: <xsl:value-of select="."/></p>-->
        </xsl:when>
        <xsl:when test="contains(., '@')">
          <xsl:message>  HINT: Missing mailto in '<xsl:value-of select="."/>'?</xsl:message>
        </xsl:when>
        <xsl:when test="starts-with(., 'file')">
          <p>Local reference available? <xsl:value-of select="."/></p>
        </xsl:when>
        <xsl:otherwise>
          <p>WARNING: Fix syntax of this link: "<span
            style="color:red"><xsl:value-of select="."/></span>"</p>
          <xsl:message>  HINT: Check syntax of this link: <xsl:value-of select="."/></xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>


<xsl:template name="getxmlbase">
  <xsl:param name="node" select="."/>
  
  <xsl:choose>
    <xsl:when test="$node/ancestor::*/@xml:base">
      <xsl:text> </xsl:text>
      <span class="xmlbase">Filename: <xsl:value-of select="$node/ancestor::*/@xml:base"/></span>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message> No ancestor with xml:base for '<xsl:value-of
        select="concat(name(.), '@id=', @id)"/>' found.</xsl:message>
    </xsl:otherwise>
  </xsl:choose>  
</xsl:template>
</xsl:stylesheet>
