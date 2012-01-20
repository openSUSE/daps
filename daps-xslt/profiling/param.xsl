<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
   xmlns:p="urn:x-suse:xmlns:docproperties"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   exclude-result-prefixes="p">


<xsl:key name="id" match="*" use="@id|@xml:id" />

<!-- Maybe obsolete in the future: -->
<xsl:param name="show.comments">0</xsl:param>
<xsl:param name="show.remarks">0</xsl:param>

<!-- Should the SUSE processing instruction be resolved?
   0 = no, 1 = yes
-->
<xsl:param name="resolve.suse-pi" select="0"/>


<!-- Used for inserting xml:base attribute -->
<xsl:param name="filename"/>


<!-- rootid: Process only this element and their childs         -->
<xsl:param name="rootid"/>

</xsl:stylesheet>
