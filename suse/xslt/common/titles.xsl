<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: $ -->
<!DOCTYPE xsl:stylesheet >
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >


<xsl:template match="refnamediv" mode="title.markup">
  <xsl:apply-templates select="refname"/>
</xsl:template>

<xsl:template match="guilabel|guimenu|guibutton|keycombo|keycap|menuchoice" mode="title.markup">
  <xsl:apply-templates select="self::node()"/>
</xsl:template>

<xsl:template match="xref" mode="title.markup">
  <xsl:call-template name="xref"/>
</xsl:template>
  
</xsl:stylesheet>

