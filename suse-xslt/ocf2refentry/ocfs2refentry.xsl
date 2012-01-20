<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- 
   Purpose: Transforms output from meta-data into DocBook refentry
   Author:  Thomas Schraitle <toms@suse.de>
-->
<!--
  toms 2008-03-12:
  The resources for Heartbeat are generated with the following steps:
  (replace ++ with two minuses; the pluses are due to XML comments)

  1. Create a temporary directory:
  # mkdir /tmp/hb/{xml,db}

  2. Extract the meta data in XML form:
  # cd /usr/lib/ocf/resource.d/heartbeat/
  # for i in *; do \
  #  echo $i; \
  #  OCF_ROOT=/usr/lib/ocf/ ./$i meta-data > /tmp/hb/xml/$i.xml; \
  # done

  3. Validate it:
  # cd /tmp/hb
  # for i in xml/*.xml; do \
  #   echo "*** $i" \
  #   xmllint ++timing ++valid ++noout ++nonet $i \
  # done

  4. Transform it to DocBook refentry:
  #  cd /tmp/hb
  #  cp /usr/lib/heartbeat/ra-api-1.dtd /tmp/hb/xml/
  #  for i in xml/*.xml; do \
  #   j=${i##*/} # Remove any dirs
  #   echo "*** $j"
  #   xsltproc ++output=db/$j ocfs2refentry.xsl $i \
  # done


-->


 <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
 <xsl:strip-space elements="*"/>

 <!-- Insert manpage volume for <manvolnum> -->
 <xsl:param name="manvolum">7</xsl:param>

 <!-- Insert a variable prefix in <command> -->
 <xsl:param name="variable.prefix">OCF_RESKEY_</xsl:param>
 
 <!-- Insert prefix in <refentrytitle> and <refname> -->
 <xsl:param name="command.prefix">ocf:</xsl:param>
 
 <!-- Separator between different action/@name -->
 <xsl:param name="separator"> | </xsl:param>

 <xsl:template match="/">
  <refentry>
    <xsl:if test="resource-agent/@name">
      <xsl:attribute name="id">
        <xsl:value-of select="concat('ref.ocfagent.',resource-agent/@name)"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates mode="root"/>
  </refentry>
 </xsl:template>

 <xsl:template match="resource-agent" mode="root">
  <xsl:param name="this" select="self::resource-agent"/>
  
  <xsl:apply-templates select="$this" mode="refmeta"/>
  <xsl:apply-templates select="$this" mode="refnamediv"/>   
  <xsl:apply-templates select="$this" mode="synopsis"/>
  <xsl:apply-templates select="$this" mode="description"/>
  <xsl:apply-templates select="$this" mode="parameters"/>
 </xsl:template>


 <!-- Empty Templates -->
 <xsl:template match="node()" mode="root"/>
 <xsl:template match="*" mode="refmeta"/>
 <xsl:template match="*" mode="refnamediv"/>
 
 <xsl:template match="*" mode="synopsis"/>
 <xsl:template match="*" mode="description"/>
 <xsl:template match="*" mode="parameters"/>
 
 
 <!-- Mode refmeta -->
 <xsl:template match="resource-agent" mode="refmeta">
  <!--<xsl:text>&#10;</xsl:text>-->
  <refmeta>
   <xsl:call-template name="refentrytitle"/>
   <xsl:call-template name="manvolum"/>
  </refmeta>
  <!--<xsl:text>&#10;</xsl:text>-->
 </xsl:template>

 <xsl:template name="refentrytitle">
  <!--<xsl:text>&#10;  </xsl:text>-->
  <refentrytitle><xsl:value-of select="concat($command.prefix, @name)"/></refentrytitle>
 </xsl:template>

 <xsl:template name="manvolum">
  <manvolnum><xsl:value-of select="$manvolum"/></manvolnum>
 </xsl:template>


 <!-- Mode refnamediv -->
 <xsl:template match="resource-agent" mode="refnamediv">
  <refnamediv>
   <xsl:call-template name="refname"/>
   <xsl:call-template name="refpurpose"/>
  </refnamediv>
 </xsl:template>
 
 <xsl:template name="refname">
  <refname><xsl:value-of select="concat($command.prefix,@name)"/></refname>
 </xsl:template>
 
 <xsl:template name="refpurpose">
  <refpurpose><xsl:apply-templates select="shortdesc"/></refpurpose>
 </xsl:template>

 <!-- Mode synopsis -->
 <xsl:template match="resource-agent" mode="synopsis">
  <refsect1><xsl:text>&#10;  </xsl:text>
   <title>Synopsis</title>
   <para>
    <xsl:apply-templates select="parameters/parameter" mode="synopsis"/>
    <xsl:apply-templates select="actions" mode="synopsis">
     <xsl:with-param name="name" select="@name"/>
    </xsl:apply-templates>
   </para>
  </refsect1>
 </xsl:template>

 <xsl:template match="parameters/parameter" mode="synopsis">
  <xsl:if test="not(@unique='1')">
   <xsl:text>[</xsl:text>
  </xsl:if>  
  <command><xsl:value-of select="concat($variable.prefix, @name)"/></command>
  <xsl:text>=</xsl:text>
  <xsl:value-of select="content/@type"/>  
  <xsl:if test="not(@unique='1')">
   <xsl:text>]</xsl:text>
  </xsl:if>  
  <xsl:text> </xsl:text>
 </xsl:template>


  <xsl:template match="actions" mode="synopsis">
   <xsl:param name="name"/>
   
   <command><xsl:value-of select="$name"/></command>
   <xsl:text> [</xsl:text>
   <xsl:apply-templates select="action" mode="synopsis"/>
   <xsl:text>]</xsl:text>
  </xsl:template>
 
 
  <xsl:template match="action" mode="synopsis">
   <xsl:value-of select="@name"/>
   <xsl:if test="following-sibling::action">
     <xsl:value-of select="$separator"/>
   </xsl:if>
  </xsl:template>


 <!-- Mode Description --> 
 <xsl:template match="resource-agent" mode="description">
    <refsect1>
      <title>Description</title>
      <xsl:apply-templates mode="description"/>
    </refsect1>
  </xsl:template>
 
  <xsl:template match="longdesc" mode="description">
    <para>
     <xsl:apply-templates mode="description"/>
    </para>
  </xsl:template>
 
 
  <!-- Mode Parameters -->
  <xsl:template match="resource-agent" mode="parameters">
    <refsect1>
      <title>Supported Parameters</title>
      <xsl:apply-templates mode="parameters"/>
    </refsect1>
  </xsl:template>
 
 <xsl:template match="resource-agent/shortdesc|resource-agent/longdesc" mode="parameters"/>
 
  <xsl:template match="parameters" mode="parameters">
   <variablelist>
    <xsl:apply-templates mode="parameters"/>
   </variablelist>
  </xsl:template>
  
  
  <xsl:template match="parameter" mode="parameters">
   <varlistentry>
    <term><command><xsl:value-of 
    select="concat($variable.prefix, @name)"/></command>
    <xsl:if test="shortdesc">
     <xsl:text>=</xsl:text>
     <xsl:apply-templates select="shortdesc" mode="parameters"/>
    </xsl:if>
    </term>
    <listitem>
      <xsl:apply-templates select="longdesc" mode="parameters"/>
    </listitem>
   </varlistentry>
  </xsl:template>
  
  
   <xsl:template match="longdesc" mode="parameters">
    <para>
      <xsl:apply-templates select="text()" mode="parameters"/>
    </para>
  </xsl:template>
 
  
  <xsl:template match="shortdesc" mode="parameters">
   <xsl:apply-templates select="text()" mode="parameters"/>
  </xsl:template>
  
</xsl:stylesheet>
