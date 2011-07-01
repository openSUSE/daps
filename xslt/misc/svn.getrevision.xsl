<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: get-xrefs.xsl 449 2005-06-22 13:30:06Z jjaeger $ -->
<!DOCTYPE xsl:stylesheet >

<!-- extracts linkends from xref elements all over the place -->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text"/>

<xsl:template match="logentry[1]">
   <xsl:value-of select="@revision"/>
</xsl:template>

<xsl:template match="text()"/>

</xsl:stylesheet>