<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: $ -->
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">


<xsl:template match="varlistentry" mode="vl.as.blocks">
  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>

  <fo:block id="{$id}" xsl:use-attribute-sets="list.item.spacing"
      keep-together.within-column="always"
      keep-with-next.within-column="always">
    <xsl:apply-templates select="term"/>
  </fo:block>

  <fo:block margin-left="1.25em">
    <xsl:apply-templates select="listitem"/>
  </fo:block>
</xsl:template>

 
</xsl:stylesheet>
