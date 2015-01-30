<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  exclude-result-prefixes="d">
 
  <xsl:import href="db5to4-core.xsl"/>
  <xsl:import href="db5to4-info.xsl"/>

  <xsl:output method="xml" indent="yes"/>
  
  <xsl:param name="doctype">db4</xsl:param>


  <!-- ================================================================= -->
  <!-- Taken from common/common.xsl -->
  <xsl:template name="filename-basename">
    <!-- We assume all filenames are really URIs and use "/" -->
    <xsl:param name="filename"></xsl:param>
    <xsl:param name="recurse" select="false()"/>
    
    <xsl:choose>
      <xsl:when test="substring-after($filename, '/') != ''">
        <xsl:call-template name="filename-basename">
          <xsl:with-param name="filename"
            select="substring-after($filename, '/')"/>
          <xsl:with-param name="recurse" select="true()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$filename"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="section.level">
    <xsl:param name="node" select="."/>
    <xsl:choose>
      <xsl:when test="local-name($node)='sect1'">1</xsl:when>
      <xsl:when test="local-name($node)='sect2'">2</xsl:when>
      <xsl:when test="local-name($node)='sect3'">3</xsl:when>
      <xsl:when test="local-name($node)='sect4'">4</xsl:when>
      <xsl:when test="local-name($node)='sect5'">5</xsl:when>
      <xsl:when test="local-name($node)='section'">
        <xsl:choose>
          <xsl:when test="$node/../../../../../../d:section">6</xsl:when>
          <xsl:when test="$node/../../../../../d:section">5</xsl:when>
          <xsl:when test="$node/../../../../d:section">4</xsl:when>
          <xsl:when test="$node/../../../d:section">3</xsl:when>
          <xsl:when test="$node/../../d:section">2</xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!--<xsl:when test="local-name($node)='refsect1' or
        local-name($node)='refsect2' or
        local-name($node)='refsect3' or
        local-name($node)='refsection' or
        local-name($node)='refsynopsisdiv'">
        <xsl:call-template name="refentry.section.level">
          <xsl:with-param name="node" select="$node"/>
        </xsl:call-template>
      </xsl:when>-->
      <xsl:when test="local-name($node)='simplesect'">
        <xsl:choose>
          <xsl:when test="$node/../../d:sect1">2</xsl:when>
          <xsl:when test="$node/../../d:sect2">3</xsl:when>
          <xsl:when test="$node/../../d:sect3">4</xsl:when>
          <xsl:when test="$node/../../d:sect4">5</xsl:when>
          <xsl:when test="$node/../../d:sect5">5</xsl:when>
          <xsl:when test="$node/../../d:section">
            <xsl:choose>
              <xsl:when test="$node/../../../../../d:section">5</xsl:when>
              <xsl:when test="$node/../../../../d:section">4</xsl:when>
              <xsl:when test="$node/../../../d:section">3</xsl:when>
              <xsl:otherwise>2</xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Taken from https://github.com/stackforge/clouddocs-maven-plugin/blob/a3621dfb4b620f3993d826649f7b944dae4b2407/src/main/resources/cloud/webhelp/profile-webhelp.xsl#L242
       and adapted to DocBook4
  -->
  <xsl:template name="CCLegalNotice">
    <xsl:if test="starts-with(string(@role),'cc-')">
      <xsl:variable name="ccid">
        <xsl:value-of select="substring-after(string(@role),'cc-')"/>
      </xsl:variable>
      <xsl:variable name="ccidURL"
        >http://creativecommons.org/licenses/<xsl:value-of
          select="$ccid"/>/3.0/legalcode</xsl:variable>
      <informaltable frame="void">
        <tgroup cols="2">
        <colspec colwidth="10%"/>
        <colspec colwidth="90%"/>
        <tbody>
          <row>
            <entry>
              <para><ulink url="{$ccidURL}">
                <inlinemediaobject>
                  <imageobject>
                    <imagedata fileref="{$ccid}.png"/>
                  </imageobject>
                </inlinemediaobject>
              </ulink></para>
            </entry>
            <entry>
              <para>Except where otherwise noted, this document is
                licensed under <ulink url="{$ccidURL}">                  
                  <emphasis role="bold"> Creative Commons Attribution <xsl:choose>
                    <xsl:when test="$ccid = 'by'"/>
                    <xsl:when test="$ccid = 'by-sa'">
                      <xsl:text>ShareAlike</xsl:text>
                    </xsl:when>
                    <xsl:when test="$ccid = 'by-nd'">
                      <xsl:text>NoDerivatives</xsl:text>
                    </xsl:when>
                    <xsl:when test="$ccid = 'by-nc'">
                      <xsl:text>NonCommercial</xsl:text>
                    </xsl:when>
                    <xsl:when test="$ccid = 'by-nc-sa'">
                      <xsl:text>NonCommercial ShareAlike</xsl:text>
                    </xsl:when>
                    <xsl:when test="$ccid = 'by-nc-nd'">
                      <xsl:text>NonCommercial NoDerivatives</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:message terminate="yes"> I don't understand
                        licence <xsl:value-of select="$ccid"/>
                      </xsl:message>
                    </xsl:otherwise>
                  </xsl:choose> 3.0 License </emphasis>
                </ulink> 
              </para>
              <para>
                <ulink url="{$ccidURL}"/>
              </para>
            </entry>
          </row>
        </tbody>
        </tgroup>
      </informaltable>
    </xsl:if>
  </xsl:template>
  
  
  <!-- Taken from clouddocs-maven-plugin@Github:src/main/resources/cloud/date.xsl -->
  <!-- 
       These templates convert ISO-8601 to more human friendly forms.

       Examples of valid inputs include:
       * 2011-03-18
       * 2011-03-18T20:05Z
  -->
  <xsl:template name="longDate">
    <xsl:param name="in"/>
    <xsl:choose>
      <xsl:when test="$in">
        <xsl:variable name="year" select="normalize-space(substring-before(string($in),'-'))"/>
        <xsl:variable name="rest" select="substring-after(string($in),'-')"/>
        <xsl:variable name="month" select="normalize-space(substring-before($rest,'-'))"/>
        <xsl:variable name="day"   select="normalize-space(substring-before(concat(substring-after($rest,'-'),'T'),'T'))"/>
        <xsl:choose>
          <xsl:when test="$month = '01'">
            <xsl:text>January</xsl:text>
          </xsl:when>
          <xsl:when test="$month = '02'">
            <xsl:text>February</xsl:text>
          </xsl:when>
          <xsl:when test="$month = '03'">
            <xsl:text>March</xsl:text>
          </xsl:when>
          <xsl:when test="$month = '04'">
            <xsl:text>April</xsl:text>
          </xsl:when>
          <xsl:when test="$month = '05'">
            <xsl:text>May</xsl:text>
          </xsl:when>
          <xsl:when test="$month = '06'">
            <xsl:text>June</xsl:text>
          </xsl:when>
          <xsl:when test="$month = '07'">
            <xsl:text>July</xsl:text>
          </xsl:when>
          <xsl:when test="$month = '08'">
            <xsl:text>August</xsl:text>
          </xsl:when>
          <xsl:when test="$month = '09'">
            <xsl:text>September</xsl:text>
          </xsl:when>
          <xsl:when test="$month = '10'">
            <xsl:text>October</xsl:text>
          </xsl:when>
          <xsl:when test="$month = '11'">
            <xsl:text>November</xsl:text>
          </xsl:when>
          <xsl:when test="$month = '12'">
            <xsl:text>December</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes">
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              Bad Month value in "<xsl:value-of select="$in"/>"
              Please use the format 2011-12-31 for
              dates.
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:choose>
          <xsl:when test="starts-with($day, '0')">
            <xsl:value-of select="substring($day, 2)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$day"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$year"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- ================================================================= -->
  <xsl:template match="/">
    
    <xsl:choose>
      <xsl:when test="$doctype = 'db4'">
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE </xsl:text>
        <xsl:value-of select="local-name(*[1])"/>
        <xsl:text disable-output-escaping="yes"> PUBLIC "-//OASIS//DTD DocBook XML V4.5//EN" "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd">
</xsl:text>
        <xsl:processing-instruction name="xml-stylesheet">
      href="urn:x-daps:xslt:profiling:docbook45-profile.xsl" 
      type="text/xml"
      title="Profiling step"</xsl:processing-instruction>
        <xsl:text>&#10;</xsl:text>       
      </xsl:when>
      <xsl:when test="$doctype = 'novdoc'">
        <xsl:text disable-output-escaping="yes">&#10;&lt;!DOCTYPE </xsl:text>
        <xsl:value-of select="local-name(*[1])"/>
        <xsl:text disable-output-escaping="yes"> PUBLIC "-//Novell//DTD NovDoc XML V1.0//EN" "novdocx.dtd" [
  &lt;!ENTITY % NOVDOC.DEACTIVATE.IDREF "IGNORE">
  &lt;!ENTITY % entities SYSTEM "entity-decl.ent">
  %entities;
]>
</xsl:text>
        <xsl:processing-instruction name="xml-stylesheet">
      href="urn:x-daps:xslt:profiling:novdoc-profile.xsl" 
      type="text/xml"
      title="Profiling step"</xsl:processing-instruction>
        <xsl:text>&#10;&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    
    
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="/*[not(@xml:lang)]">
    <xsl:element name="{local-name()}">
      <xsl:attribute name="lang">en</xsl:attribute><!-- Set default value -->
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>


  <!-- Rewrite @audience -> condition -->
  <xsl:template match="@audience">
    <xsl:attribute name="condition">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
  
  <xsl:template match="d:author[d:affiliation]">
    <xsl:apply-templates select="*[not(self::d:affiliation)]"/>
    <xsl:element name="corpauthor">
      <xsl:apply-templates select="d:affiliation/*"/>
    </xsl:element>
  </xsl:template>


  <xsl:template match="d:affiliation/d:orgname">
    <!-- We don't need this, so skip it: -->
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="d:code">
    <xsl:element name="literal">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="d:legalnotice">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@role"/>
      <para><!-- We need para here unfortunately -->
        <xsl:call-template name="CCLegalNotice"/>
      </para>
    </xsl:element>
  </xsl:template>


  <xsl:template match="d:legalnotice/*"/>

  
  <xsl:template match="d:imagedata/@fileref">
    <xsl:variable name="basename">
      <xsl:call-template name="filename-basename">
        <xsl:with-param name="filename" select="."/>
        <xsl:with-param name="recurse" select="true()"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:attribute name="fileref">
      <xsl:value-of select="$basename"/>
    </xsl:attribute>
  </xsl:template>


  <xsl:template match="d:imagedata/@contentwidth">
    <xsl:choose>
      <xsl:when test="not(@width)">
        <xsl:attribute name="width">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="../@width = ."/>
      <xsl:otherwise>
        <xsl:attribute name="contentwidth">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="d:imagedata/@format"/>

  <!-- Skip methodname -->
  <xsl:template match="d:methodname[d:link]">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="d:programlisting">
    <xsl:element name="screen">
      <xsl:attribute name="remap">programlisting</xsl:attribute>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="d:screen/d:computeroutput | d:screen/d:userinput">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="d:section|d:simplesect">
    <xsl:variable name="depth">
      <xsl:call-template name="section.level"/>
    </xsl:variable>
    
    <xsl:element name="sect{$depth}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- Revhistory -->
  <xsl:template match="processing-instruction('rax')[normalize-space(.) = 'revhistory']">
    <xsl:apply-templates select="//d:revhistory[1]" mode="revhistory"/>
  </xsl:template>
  
  <xsl:template match="d:revhistory" mode="revhistory">
    <informaltable rules="all" remap="revhistory">        
      <tgroup cols="2">
        <colspec colwidth="20%"/>
        <colspec colwidth="80%"/>
        <thead>
          <row>
            <entry align="center"><para>Revision Date</para></entry>
            <entry align="center"><para>Summary of Changes</para></entry>
          </row>
        </thead>
        <tbody>
          <xsl:apply-templates mode="revhistory"/>
        </tbody>
      </tgroup>
    </informaltable>
  </xsl:template>
  
  <xsl:template match="d:revision" mode="revhistory">
    <row>
      <entry>
        <para>
          <xsl:call-template name="longDate">
             <xsl:with-param name="in"  select="d:date"/>
          </xsl:call-template>
        </para>
      </entry>
      <entry>
        <xsl:apply-templates select="d:revdescription/*"/>
      </entry>
    </row>
  </xsl:template>
  
</xsl:stylesheet>
