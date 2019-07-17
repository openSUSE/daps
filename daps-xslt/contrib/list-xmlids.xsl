<?xml version="1.0"?>
<!--
   Purpose:
     Lists all xml:id's

   Parameters:
     * separator (default ' ') the separated between consecutive xml:id's
     * endseparator (default linebreak): the final character to print

   Input:
     DocBook 5 document

   Output:
     Text

   See also:
      get-headlines-ids.xsl

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2019 SUSE Linux GmbH

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   version="1.0">

   <xsl:output method="text"/>

<!-- this stylesheets extracts all ids -->
<xsl:param name="separator" select="' '"/>
<xsl:param name="endseparator" select="'&#10;'"/>


<xsl:template match="text()"/>

<xsl:template match="/">
 <xsl:apply-templates/>
 <xsl:value-of select="$endseparator"/>
</xsl:template>


<xsl:template match="*[@xml:id]">
   <xsl:value-of select="concat(@xml:id, $separator)"/>
   <xsl:apply-templates />
</xsl:template>

</xsl:stylesheet>
