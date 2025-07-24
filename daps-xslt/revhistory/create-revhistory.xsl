<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Insert <revhistory> if not available

   Parameters:
     * revdate (string): A date that is inserted into revhistory/revision[1]/date.
       The value has to be in the format YYYY-MM-DD
     * revdescr (string): The description of the revision.

   Input:
     DocBook 5 source

   Output:
     DocBook 5 with a <revhistory> element.

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2025 SUSE Software Solutions Germany GmbH

-->
<xsl:stylesheet version="1.0" 
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://docbook.org/ns/docbook">

  <xsl:import href="../common/copy.xsl"/>
  <xsl:output method="xml" indent="yes"/>
  <xsl:preserve-space elements="d:info"/>

  <xsl:param name="revdate"/>
  <xsl:param name="revdescr">Initial version<xsl:value-of select="concat(' ', $revdate)"/></xsl:param>
  <xsl:param name="with-doctype" select="1" />
  <xsl:param name="revhistory-xmlid-prefix">rh-</xsl:param>


  <xsl:template match="/">
    <xsl:if test="$revdate = ''">
      <xsl:message terminate="yes">ERROR: Missing 'revdate' XSLT parameter!</xsl:message>
    </xsl:if>
    <xsl:if test="$with-doctype">
      <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE chapter
[
  &lt;!ENTITY % entities SYSTEM "generic-entities.ent">
  %entities;
]>&#10;&#10;</xsl:text>
    </xsl:if>
    <xsl:apply-templates />
  </xsl:template>


   <xsl:template match="d:book/d:info[not(d:revhistory)]
                        | d:article/d:info[not(d:revhistory)]
                        | d:bibliography/d:info[not(d:revhistory)]
                        | d:chapter/d:info[not(d:revhistory)]
                        | d:appendix/d:info[not(d:revhistory)]
                        | d:glossary/d:info[not(d:revhistory)]
                        | d:part/d:info[not(d:revhistory)]
                        | d:reference/d:info[not(d:revhistory)]
                        ">
     <info>
       <xsl:apply-templates/>
       <revhistory>
          <xsl:attribute name="xml:id">
           <xsl:value-of select="concat($revhistory-xmlid-prefix, translate((ancestor-or-self::*/@xml:id)[1], ': /.', '_'))"/>
         </xsl:attribute>
         <xsl:text>&#10;   </xsl:text>
         <revision>
           <xsl:text>&#10;     </xsl:text>
           <date><xsl:value-of select="$revdate"/></date>
           <xsl:text>&#10;     </xsl:text>
           <revdescription>
             <xsl:text>&#10;       </xsl:text>
             <para><xsl:value-of select="$revdescr"/></para>
             <xsl:text>&#10;     </xsl:text>
           </revdescription>
           <xsl:text>&#10;   </xsl:text>
         </revision>
         <xsl:text>&#10; </xsl:text>
       </revhistory>
       <xsl:text>&#10;</xsl:text>
     </info>
   </xsl:template>

</xsl:stylesheet>