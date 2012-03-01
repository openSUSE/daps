<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  version="1.0"
   xmlns:p="urn:x-suse:xmlns:docproperties"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   exclude-result-prefixes="p">

<xsl:param name="debug-suse-pi" select="0"/>
<xsl:param name="projectfile"/>
<xsl:param name="projectfilenodes" select="document($projectfile, /)"/>
<xsl:param name="productname" 
   select="$projectfilenodes/p:docproperties/p:productspec/p:productname[1]"/>
<xsl:param name="productnamereg" 
   select="$projectfilenodes/p:docproperties/p:productspec/p:productnamereg[1]"/>
<xsl:param name="productnumber"
   select="$projectfilenodes/p:docproperties/p:productspec/p:productnumber[1]"/>
<xsl:param name="booktitle" 
   select="$projectfilenodes/p:docproperties/p:productspec/p:title[1]"/>


<xsl:template match="processing-instruction('suse')"
              name="suse-pi"
              mode="profile">
      <xsl:param name="resolve" select="$resolve.suse-pi"/>
      <xsl:variable name="name">
         <xsl:call-template name="pi-attribute">
            <xsl:with-param name="pis" select="."/>
            <xsl:with-param name="attribute">name</xsl:with-param>
         </xsl:call-template>  
      </xsl:variable>
      <xsl:variable name="result">
         <xsl:choose>
            <xsl:when test="$name = 'productnumber'">
               <xsl:value-of select="$productnumber"/>
            </xsl:when>
            <xsl:when test="$name = 'productname'">
               <xsl:value-of select="$productname"/>
            </xsl:when>
            <xsl:when test="$name = 'productnamereg'">
              <xsl:value-of select="$productnamereg"/>
            </xsl:when>
            <xsl:when test="$name = 'title'">
               <xsl:value-of select="$booktitle"/>
            </xsl:when>      
         </xsl:choose>
      </xsl:variable>
            
  <xsl:if test="$debug-suse-pi != '0'">
      <!--<xsl:message>SUSE PI: 
         name = <xsl:value-of select="$name"/>
         result = "<xsl:value-of select="$result"/>"
         count = <xsl:value-of select="count($projectfilenodes//*)"/>
         parent = "<xsl:value-of select="name(..)"/>"
         title  = "<xsl:value-of select="$booktitle"/>"
         productnumber = "<xsl:value-of select="$productnumber"/>"
      </xsl:message>-->
    <xsl:message>SUSE PI: <xsl:value-of select="concat($name, 
      ' -> ', '&quot;', $result, '&quot;')"/></xsl:message>
  </xsl:if>
      
  <xsl:choose>
    <!-- Test, if suse PI has to be resolved -->
    <xsl:when test="$resolve != 0">
      <xsl:choose>
        <!-- Test, if there is a result: -->
        <xsl:when test="$result != ''">
          <xsl:value-of select="$result"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>WARNING: Could not resolve suse PI "</xsl:text>
            <xsl:value-of select="$name"/>
            <xsl:text>"!</xsl:text>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <!-- Just copy the PI, but don't try to resolve it -->
      <xsl:copy-of select="."/>
    </xsl:otherwise>
  </xsl:choose>
  
  
</xsl:template>
   
</xsl:stylesheet>
