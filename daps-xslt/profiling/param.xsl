<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
   xmlns:p="urn:x-suse:xmlns:docproperties"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   exclude-result-prefixes="p">


<xsl:key name="id" match="*" use="@id|@xml:id" />

<!-- Maybe obsolete in the future: -->
<!-- show comments and/or remarks
     0 = no, 1 = yes
-->
<xsl:param name="show.comments" select="0"/>
<xsl:param name="show.remarks" select="0"/>

<!-- Should the SUSE processing instruction be resolved?
   0 = no, 1 = yes
-->
<xsl:param name="resolve.suse-pi" select="0"/>


<!-- Used for inserting xml:base attribute -->
<xsl:param name="filename"/>


<!-- rootid: Process only this element and their children  -->
<xsl:param name="rootid"/>

</xsl:stylesheet>
