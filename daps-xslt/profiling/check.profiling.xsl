<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- Checks if an element needs to be profiled
     returns 0 (needs to be profiled) or 1 (no profiling necessary)

     Taken from the original DocBook XSL Stylesheets,
     see profiling/profile-mode.xsl
-->

<xsl:include href="pi-attribute.xsl"/>

<xsl:param name="provo.root"/>

 <!-- Profiling parameters -->
 <xsl:param name="profile.arch" select="''"/>
 <xsl:param name="profile.audience" select="''"/>
 <xsl:param name="profile.condition" select="''"/>
 <xsl:param name="profile.conformance" select="''"/>
 <xsl:param name="profile.lang" select="''"/>
 <xsl:param name="profile.os" select="''"/>
 <xsl:param name="profile.revision" select="''"/>
 <xsl:param name="profile.revisionflag" select="''"/>
 <xsl:param name="profile.role" select="''"/>
 <xsl:param name="profile.security" select="''"/>
 <xsl:param name="profile.status" select="''"/>
 <xsl:param name="profile.userlevel" select="''"/>
 <xsl:param name="profile.vendor" select="''"/>
 <xsl:param name="profile.wordsize" select="''"/>
 
 <xsl:param name="profile.attribute" select="''"/>
 <xsl:param name="profile.value" select="''"/>
 
 <xsl:param name="profile.separator" select="';'"/>
 
 <xsl:param name="profiling.attributes.enabled">
  <xsl:if test="$profile.arch">arch<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.audience">audience<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.condition">condition<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.conformance">conformance<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.lang">lang<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.os">os<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.revision">revision<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.revisionflag">revisionflag<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.role">role<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.security">security<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.status">status<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.userlevel">userlevel<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.vendor">vendor<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.userlevel">userlevel<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.wordsize">wordsize<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.vendor">userlevel<xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.value"><xsl:value-of select="$profile.attribute"/><xsl:text> </xsl:text></xsl:if>
 </xsl:param>
 
 <xsl:param name="profiling.values.merged">
  <xsl:if test="$profile.arch"><xsl:value-of select="$profile.arch"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.audience"><xsl:value-of select="$profile.audience"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.condition"><xsl:value-of select="$profile.condition"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.conformance"><xsl:value-of select="$profile.conformance"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.lang"><xsl:value-of select="$profile.lang"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.os"><xsl:value-of select="$profile.os"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.revision"><xsl:value-of select="$profile.revision"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.revisionflag"><xsl:value-of select="$profile.revisionflag"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.role"><xsl:value-of select="$profile.role"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.security"><xsl:value-of select="$profile.security"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.status"><xsl:value-of select="$profile.status"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.userlevel"><xsl:value-of select="$profile.userlevel"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.vendor"><xsl:value-of select="$profile.vendor"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.userlevel"><xsl:value-of select="$profile.userlevel"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.wordsize"><xsl:value-of select="$profile.wordsize"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.vendor"><xsl:value-of select="$profile.userlevel"/><xsl:text> </xsl:text></xsl:if>
  <xsl:if test="$profile.value"><xsl:value-of select="$profile.value"/><xsl:text> </xsl:text></xsl:if>
 </xsl:param>
 
 <xsl:param name="profiling.enabled">
  <xsl:choose>
   <xsl:when test="not(normalize-space($profiling.attributes.enabled))">0</xsl:when>
   <xsl:otherwise>1</xsl:otherwise>
  </xsl:choose>
 </xsl:param>
 

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
