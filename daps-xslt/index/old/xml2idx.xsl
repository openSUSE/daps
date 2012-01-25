<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--
    Generates only the structure of the document but
    without text nodes.
-->

<xsl:import href="../common/copy.xsl"/>

<!-- Omit any any text node -->
<xsl:template match="text()" />

<!-- Do not forget to copy text nodes in our indexterms -->
<xsl:template match="primary/text()|secondary/text()|tertiary/text()">
    <xsl:value-of select="."/>
</xsl:template>

</xsl:stylesheet>
