<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Extract screen elements and write separate files used by @role
     Consider double entries in @role

   Parameters:
     * base.dir (default: "")
       Write to a different directory, otherwise use the current directory
     * chunk.quietly (default: 0)
       Suppress debugging message
     * prefix (default: '.txt')
       Filename prefix

   Input:
     DocBook 4/5 document

   Output:
     No main output, but secondary output from write.chunk as text files

   Example:
     <screen>Oh no! No @role attribute found! :-(</screen>
     <screen role="foo1">Hello World for foo1</screen>
     <screen role="foo1">Hello World for foo1</screen>
     <screen role="foo2">Hello World for foo2</screen>

   Result:
     You will get an error as two 'foo1' filenames are available. They would
     overwrite each other.
     If you correct them and replace the last 'foo1' with 'foo3' you will get:

     ERROR: No ID found, look for screen starting with "Oh no! No ..."
     Writing foo1.txt for screen
     Writing foo3.txt for screen
     Writing foo2.txt for screen

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2015, Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook">

  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/chunker.xsl"/>

  <xsl:output method="text"/>

  <xsl:key name="role" match="*" use="@role"/>

  <!-- Parameters   -->
  <xsl:param name="base.dir"/>

  <xsl:param name="chunk.quietly" select="0"/>

  <xsl:param name="prefix">.txt</xsl:param>

  <!-- Templates    -->
  <xsl:template match="text()"/>


  <xsl:template match="screen[not(@role)] | d:screen[not(@role)]">
    <xsl:message>
       <xsl:text>ERROR: No ID found, look for screen starting with </xsl:text>
       <xsl:value-of select="concat('&quot;', substring(normalize-space(.), 1, 10), '...&quot;')"/>
    </xsl:message>
  </xsl:template>


  <xsl:template match="screen | d:screen">
    <xsl:variable name="role" select="@role"/>
    <xsl:variable name="filename" select="concat($base.dir, $role, $prefix)"/>
    <xsl:variable name="contents">
      <xsl:apply-templates mode="screen"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="count(key('role', $role)) > 1">
          <xsl:message terminate="yes">
            <xsl:text>ERROR: filename in @role appears more than once: </xsl:text>
            <xsl:value-of select="$role"/>
          </xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="write.chunk">
          <xsl:with-param name="content" select="$contents"/>
          <xsl:with-param name="filename" select="$filename"/>
          <xsl:with-param name="encoding">UTF-8</xsl:with-param>
          <xsl:with-param name="omit-xml-declaration" select="'yes'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>