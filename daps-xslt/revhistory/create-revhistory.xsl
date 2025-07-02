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

  <xsl:param name="revdate"/>
  <xsl:param name="revdescr">Initial version<xsl:value-of select="concat(' ', $revdate)"/></xsl:param>


   <xsl:template match="d:info[not(d:revhistory)]">
     <info>
       <xsl:apply-templates/>
       <revhistory xml:id="rh-{/*/@xml:id}">
         <revision>
           <date><xsl:value-of select="$revdate"/></date>
           <revdescription>
             <para><xsl:value-of select="$revdescr"/></para>
           </revdescription>
         </revision>
       </revhistory>
       <xsl:text>&#10;</xsl:text>
     </info>
   </xsl:template>

</xsl:stylesheet>