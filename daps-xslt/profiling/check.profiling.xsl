<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- Checks if an element needs to be profiled
     returns 0 (needs to be profiled) or 1 (no profiling necessary)

     Taken from the original DocBook XSL Stylesheets,
     see profiling/profile-mode.xsl
-->

<xsl:include href="pi-attribute.xsl"/>

<xsl:param name="provo.root"/>

<xsl:template name="check.profiling">
  <xsl:param name="context" select="."/>
  <xsl:param name="attributes" select="$profiling.attributes.enabled"/>
  <xsl:param name="values" select="$profiling.values.merged"/>

  <!-- Everything has to match, i.e.: we can stop as soon as the first one does
  not match. -->

  <xsl:variable name="current.attribute" select="substring-before($attributes, ' ')"/>

  <xsl:variable name="current.value" select="substring-before($values, ' ')"/>

  <xsl:variable name="attribute.content">
    <xsl:if test="$context/@*[local-name()=$current.attribute]">
      <xsl:call-template name="cross.compare">
        <xsl:with-param name="a" select="$current.value"/>
        <xsl:with-param name="b" select="$context/@*[local-name()=$current.attribute]"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="attribute.ok"
                select="not($context/@*[local-name()=$current.attribute]) or
                        $attribute.content != '' or
                        $context/@*[local-name()=$current.attribute] = ''"/>

  <xsl:choose>
    <xsl:when test="not($attribute.ok)">0</xsl:when>
    <xsl:otherwise>
      <xsl:variable name="next.attributes" select="substring-after($attributes, ' ')"/>
      <xsl:choose>
        <xsl:when test="$next.attributes">
          <xsl:call-template name="check.profiling">
            <xsl:with-param name="attributes" select="$next.attributes"/>
            <xsl:with-param name="values" select="substring-after($values, ' ')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<xsl:template name="profile.pi">
  <xsl:variable name="os.attr">
         <xsl:call-template name="pi-attribute">
            <xsl:with-param name="pis" select="."/>
            <xsl:with-param name="attribute" select="'os'"/>
         </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="os.content">
         <xsl:if test="$os.attr">
            <xsl:call-template name="cross.compare">
               <xsl:with-param name="a" select="$profile.os"/>
               <xsl:with-param name="b" select="$os.attr"/>
            </xsl:call-template>
         </xsl:if>
  </xsl:variable>
  <xsl:variable name="os.ok" select="not($os.attr) or not($profile.os) or
         $os.content != '' or $os.attr = ''"/>

   <xsl:choose>
     <xsl:when test="$os.ok">1</xsl:when>
     <xsl:otherwise>0</xsl:otherwise>
   </xsl:choose>
</xsl:template>


<xsl:template match="processing-instruction()" mode="profile">
  <xsl:variable name="result">
     <xsl:call-template name="profile.pi"/>
  </xsl:variable>
  <xsl:if test="$result = 1">
     <xsl:copy/>
     <xsl:text>&#10;</xsl:text>
   </xsl:if>
</xsl:template>


<xsl:template match="processing-instruction('provo')" mode="profile">
   <xsl:variable name="result">
      <xsl:call-template name="profile.pi"/>
   </xsl:variable>
   <xsl:variable name="dirname">
      <xsl:call-template name="pi-attribute">
        <xsl:with-param name="pis" select="."/>
        <xsl:with-param name="attribute" select="'dirname'"/>
      </xsl:call-template>
   </xsl:variable>
   <xsl:choose>
      <xsl:when test="$result = 1">
         <xsl:processing-instruction name="{local-name()}">
            <xsl:choose>
               <xsl:when test="$provo.root = ''">
                  <xsl:value-of select="."/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>dirname=</xsl:text>
                  <xsl:value-of select="concat('&quot;', $provo.root, '/', $dirname, '&quot;')"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:processing-instruction>
      </xsl:when>
      <xsl:otherwise/>
   </xsl:choose>
</xsl:template>

</xsl:stylesheet>
