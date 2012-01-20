<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- 
  Replaced all 'dbhtml' PIs to 'dbjsp'

-->

  <xsl:template name="pi.dbhtml_background-color">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'background-color'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_bgcolor">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'bgcolor'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_cellpadding">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'cellpadding'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_cellspacing">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'cellspacing'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_class">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'class'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_dir">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'dir'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_filename">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'filename'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_funcsynopsis-style">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'funcsynopsis-style'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_img.src.path">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'img.src.path'"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="pi.dbhtml_label-width">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'label-width'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_linenumbering.everyNth">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'linenumbering.everyNth'"
      />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_linenumbering.separator">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute"
        select="'linenumbering.separator'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_linenumbering.width">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'linenumbering.width'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_list-presentation">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'list-presentation'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_list-width">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'list-width'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_row-height">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'row-height'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_start">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'start'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_table-summary">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'table-summary'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_table-width">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'table-width'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_term-presentation">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'term-presentation'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_term-separator">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'term-separator'"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="pi.dbhtml_term-width">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'term-width'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pi.dbhtml_toc">
    <xsl:param name="node" select="."/>
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis"
        select="$node/processing-instruction('dbjsp')"/>
      <xsl:with-param name="attribute" select="'toc'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="dbhtml-attribute">
    <!-- * dbhtml-attribute is an interal utility template for retrieving -->
    <!-- * pseudo-attributes/parameters from PIs -->
    <xsl:param name="pis" select="processing-instruction('dbjsp')"/>
    <xsl:param name="attribute">filename</xsl:param>
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis" select="$pis"/>
      <xsl:with-param name="attribute" select="$attribute"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="processing-instruction('dbjsp')">
    <!-- nop -->
  </xsl:template>


</xsl:stylesheet>
