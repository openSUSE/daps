<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

  <xsl:import href="rootid.xsl"/>
  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/lib/lib.xsl"/>
  <xsl:import href="../profiling/suse-pi.xsl"/>
  
  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="resolve.suse-pi" select="1"/>
  <xsl:param name="debug-suse-pi" select="0"/>

  <xsl:template match="text()"/>


  <xsl:template match="article/title">
    <!--<xsl:message>bookinfo/title</xsl:message>-->
    <xsl:variable name="result">
      <xsl:apply-templates select="." mode="booktitle"/>
    </xsl:variable>

    <xsl:value-of select="normalize-space($result)"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="article/title/text()" mode="booktitle">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="article/title//processing-instruction('suse')" mode="booktitle">
    <xsl:call-template name="suse-pi"/>
  </xsl:template>
  
  <!-- articleinfo/ -->
  <xsl:template match="articleinfo/productname">
    <xsl:variable name="result">
      <xsl:apply-templates select="." mode="booktitle"/>
    </xsl:variable>

    <xsl:value-of select="normalize-space($result)"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="articleinfo/title/*" mode="booktitle">
    <xsl:apply-templates select="node()|text()" mode="booktitle"/>
  </xsl:template>

  <xsl:template match="articleinfo/title/text()" mode="booktitle">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="articleinfo/title//processing-instruction('suse')" mode="booktitle">
    <xsl:call-template name="suse-pi"/>
  </xsl:template>

  <xsl:template match="articleinfo/productname">
    <xsl:variable name="result">
      <xsl:apply-templates select="." mode="booktitle"/>
    </xsl:variable>

    <xsl:value-of select="normalize-space($result)"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="articleinfo/productname/*" mode="booktitle">
    <xsl:apply-templates select="node()|text()" mode="booktitle"/>
  </xsl:template>
  
  <xsl:template match="articleinfo/productname/text()" mode="booktitle">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="articleinfo/productname//processing-instruction('suse')" mode="booktitle">
    <xsl:call-template name="suse-pi"/>
  </xsl:template>
  
  <!-- articleinfo/productnumber -->
  <xsl:template match="articleinfo/productnumber" priority="10">
    <xsl:variable name="result">
      <xsl:apply-templates select="." mode="booktitle"/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($result)"/>
  </xsl:template>

  <xsl:template match="articleinfo/productnumber/*" mode="booktitle">
    <xsl:apply-templates select="node()|text()" mode="booktitle"/>
  </xsl:template>
  
  <xsl:template match="articleinfo/productnumber/text()" mode="booktitle">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="articleinfo/productnumber//processing-instruction('suse')" mode="booktitle">
    <xsl:call-template name="suse-pi"/>
  </xsl:template>
  
  <xsl:template match="articleinfo/productnumber">
    <xsl:value-of select="."/>
  </xsl:template>


  <!-- bookinfo -->
  <xsl:template match="articleinfo|bookinfo">
    <xsl:apply-templates select="title"/>
    <xsl:apply-templates select="productname"/>
    <xsl:apply-templates select="productnumber"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <!-- bookinfo/title -->
  <xsl:template match="bookinfo/title">
    <!--<xsl:message>bookinfo/title</xsl:message>-->
    <xsl:variable name="result">
      <xsl:apply-templates select="." mode="booktitle"/>
    </xsl:variable>

    <xsl:value-of select="normalize-space($result)"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="bookinfo/title/*" mode="booktitle">
    <xsl:apply-templates select="node()|text()" mode="booktitle"/>
  </xsl:template>

  <xsl:template match="bookinfo/title/text()" mode="booktitle">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="bookinfo/title//processing-instruction('suse')" mode="booktitle">
    <xsl:call-template name="suse-pi"/>
  </xsl:template>

  <!-- bookinfo/productname -->
  <xsl:template match="bookinfo/productname">
    <xsl:variable name="result">
      <xsl:apply-templates select="." mode="booktitle"/>
    </xsl:variable>

    <xsl:value-of select="normalize-space($result)"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="bookinfo/productname/*" mode="booktitle">
    <xsl:apply-templates select="node()|text()" mode="booktitle"/>
  </xsl:template>
  
  <xsl:template match="bookinfo/productname/text()" mode="booktitle">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="bookinfo/productname//processing-instruction('suse')" mode="booktitle">
    <xsl:call-template name="suse-pi"/>
  </xsl:template>
  
  <!-- bookinfo/productnumber -->
  <xsl:template match="bookinfo/productnumber" priority="10">
    <xsl:variable name="result">
      <xsl:apply-templates select="." mode="booktitle"/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($result)"/>
  </xsl:template>

  <xsl:template match="bookinfo/productnumber/*" mode="booktitle">
    <xsl:apply-templates select="node()|text()" mode="booktitle"/>
  </xsl:template>
  
  <xsl:template match="bookinfo/productnumber/text()" mode="booktitle">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="bookinfo/productnumber//processing-instruction('suse')" mode="booktitle">
    <xsl:call-template name="suse-pi"/>
  </xsl:template>
  
  <xsl:template match="bookinfo/productnumber">
    <xsl:value-of select="."/>
  </xsl:template>
  

  
</xsl:stylesheet>
