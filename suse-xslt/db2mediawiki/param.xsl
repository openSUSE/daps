<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: param.xsl 10304 2006-06-22 09:06:18Z toms $ -->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- Should @id be inserted as a comment? 0=no, 1=yes -->
    <xsl:param name="add.id.as.comments" select="1"/>

    <!-- Place the title of a "formal" object before or after the content.
         NOT USED AT THE MOMENT!
    -->
    <xsl:param name="formal.title.placement">
figure before
example before
equation before
table before
procedure before
task before
    </xsl:param>
    
    <xsl:param name="menuchoice.menu.separator"> → </xsl:param>
    <xsl:param name="menuchoice.separator" select="'+'"/>

    <!-- Use only a part of your document -->
    <xsl:param name="rootid"/>

    <xsl:param name="table.style">style="border:1px solid black;border-collapse:collapse;"</xsl:param>
    <xsl:param name="table.header.style">style="background:#efefef; border-bottom:1px solid black"</xsl:param>
    <xsl:param name="table.entry.style">style="border-bottom:1px dotted grey"</xsl:param>

    <xsl:param name="text.wrap" select="0"/>
    <xsl:param name="text.width" select="60"/>

    <!-- Should we use Wiki templates? Only useful, if the current Wiki system has some -->
    <xsl:param name="use.wikitemplates" select="1"/>

    <!-- Use a category for all links, images, etc. -->
    <xsl:param name="wiki.category"/>
    <!-- Used for Templates -->
    <xsl:param name="wiki.template.prefix">daps</xsl:param>

</xsl:stylesheet>
