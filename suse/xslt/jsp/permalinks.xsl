<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  
  <xsl:template name="addstatus">
  <xsl:param name="id"/>
  <xsl:param name="title"/>

   <xsl:if test="($draft.mode = 'yes' or $draft.mode = 'maybe') and ../@status">
     <span class="status">
       <xsl:value-of select="../@status"/>
     </span>
   </xsl:if>
</xsl:template>

<xsl:template name="permalink">
  <xsl:param name="id"/>
  <xsl:param name="title"/>
  
  <!--<xsl:message>Permalink: <xsl:value-of 
    select="concat(name(), ': ', $title)"/></xsl:message>-->
  
  <xsl:if test="$generate.permalink != '0'">
  <span class="permalink">
      <a alt="Permalink" title="Copy Permalink">
        <!--<xsl:call-template name="generate.html.title"/>--> 
        <xsl:attribute name="href">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="$id"/>
        </xsl:attribute>
        <xsl:text>¶</xsl:text>
      </a>
  </span>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>