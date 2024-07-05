<?xml version="1.0" encoding="UTF-8"?>
<!--

   Purpose:
     Find empty inline elements in our sources.
     These elements cause layout issues in HTML.

   Parameters:
     prefix:  the prefix to use for the output XPath (default "d")
              (without the colon)

   Input:
     DocBook 5 document

   Output:
     Text output or nothing
     The XPath doesn't take into account namespaces. You can assume, all
     element names are bound to the DocBook 5 namespace.

   Author:
     Thomas Schraitle <toms@opensuse.org>

   Copyright (C) 2023 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xpath.location.xsl"/>
  <xsl:output method="text"/>

  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="d:screen d:programlisting"/>

<!--  <xsl:param name="prefix">d</xsl:param>-->


  <xsl:template name="error">
    <xsl:param name="node" select="."/>
    <xsl:param name="id">
      <xsl:choose>
        <xsl:when test="($node/ancestor-or-self::*/@xml:id)[last()]">
          <xsl:value-of select="($node/ancestor-or-self::*/@xml:id)[last()]"/>
        </xsl:when>
        <xsl:otherwise>n/a</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="title" select="($node/ancestor-or-self::*/d:title|$node/ancestor-or-self::*/d:info/d:title)[last()]"/>
    <xsl:param name="level">ERROR</xsl:param>
    <xsl:param name="msg">Empty inline found.</xsl:param>

    <xsl:message><xsl:value-of
      select="concat('[', $level, '] ', $msg, ' Element &lt;', local-name($node), '>')"
       /> located near id=<xsl:value-of
        select="$id"/>, title=<xsl:value-of select="normalize-space($title)"/>
        XPath=<xsl:call-template name="xpath.location">
          <xsl:with-param name="prefix" select="$prefix"/>
        </xsl:call-template>
    </xsl:message>
  </xsl:template>


  <!-- Templates -->
  <xsl:template match="text()"/>

  <xsl:template match="d:abbrev|d:accel|d:acronym|d:alt|d:arg|d:bridgehead|
                       d:buildtarget|d:citation|d:citebiblioid|d:citerefentry|
                       d:citetitle|d:city|d:classname|d:code|d:command|
                       d:computeroutput|d:confdates|d:confgroup|d:confnum|
                       d:confsponsor|d:conftitle|d:constant|d:constraint|
                       d:contractnum|d:contractsponsor|d:contrib|
                       d:copyright|d:country|d:database|d:edition|
                       d:email|d:enumidentifier|d:enumitemdescription|d:enumname|
                       d:enumvalue|d:emphasis|d:envar|d:errorcode|d:errorname|d:errortext|
                       d:errortype|d:exceptionname|d:fax|d:filename|d:firstname|
                       d:foreignphrase|d:funcdef|d:function|d:guilabel|d:guimenu|
                       d:guimenuitem|d:guisubmenu|d:hardware|d:holder|d:honorific|
                       d:initializer|d:issuenum|d:jobtitle|d:keycap[not(@function)]|d:keycode|d:keysym|
                       d:keyword|d:label|d:lhs|d:lineage|d:lineannotation|
                       d:literal|d:macrodef|d:macroname|d:manvolnum|d:markup|
                       d:mathphrase|d:member|d:modfier|d:msgaud|d:msglevel|d:msgtext|
                       d:nonterminal|d:ooclass|d:ooexception|d:oointerface|
                       d:option|d:optional|d:org|d:orgdiv|d:orgname|d:otheraddr|
                       d:othername|d:package|d:pagenums|d:paramdef|d:parameter|
                       d:phone|d:pob|d:postcode|d:primary|d:primarie|d:prompt|
                       d:property|d:publisher|d:publishername|d:quote|d:refclass|
                       d:refname|d:refpurpose|d:remark|d:replaceable|d:returnvalue|
                       d:rhs|d:segtitle|d:seriesvolnums|d:state|d:street|d:subjectterm|
                       d:surname|d:systemitem|d:tag|d:tertiary|d:tertiaryie|d:title|
                       d:token|d:type|d:typedefname|d:unionname|d:uri|d:varname|d:volumenum|
                       d:year
                       ">
    <xsl:choose>
      <!-- Don't report inlines with a xref -->
      <xsl:when test="d:xref"/>
      <xsl:when test="normalize-space(.) = ''">
        <xsl:call-template name="error"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="d:indexterm">
    <xsl:call-template name="error">
      <!-- <xsl:with-param name="level">WARN</xsl:with-param> -->
      <xsl:with-param name="msg">Deprecated indexterm found (primary=<xsl:value-of select="normalize-space(d:primary)"/>).</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
