<?xml version="1.0" encoding="ASCII"?>
<!-- 
   Purpose:  Inserts Meta information
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:dp="urn:x-suse:xmlns:docproperties" 
  xmlns="http://www.w3.org/1999/xhtml">

 <!-- Use a key, to find the node dp:filename in 'METAFILE' -->
 <xsl:param name="metafilename" select="'METAFILE'"/>
 <xsl:key name="status" match="dp:filename" use="self::dp:filename"/>
 
 
<xsl:template name="getmetadata">
 <xsl:param name="filename" select="'UNKNOWN'"/>

 <xsl:variable name="metafilenodes" select="document($metafilename,.)/*/dp:filename"/>
 <xsl:variable name="dpfilenamenode" select="$metafilenodes[generate-id(.) =   generate-id(key('status', $filename))]"/>
  <div class="doc-status">
   <xsl:choose>
    <xsl:when test="count($dpfilenamenode) = 0">
     <xsl:message>WARNING: Could not retrieve metadata for filename <xsl:value-of select="concat(&quot;'&quot;, $filename, &quot;' &quot;)"/></xsl:message>
      <span class="ds-error">Status information could not be retrieved.</span>
    </xsl:when>
    <xsl:otherwise>
      <span class="ds-head">Status information</span>
      <ul>
       <li><span class="ds-label">Filename: </span><xsl:value-of select="$filename"/></li>
       <li><span class="ds-label">Maintainer: </span><xsl:value-of select="$dpfilenamenode/@maintainer"/></li>
       <li>
         <span class="ds-label">Status: </span><xsl:value-of select="$dpfilenamenode/@status"/>
         <xsl:if test="$dpfilenamenode/@prelim = 'yes'">
           <xsl:text>, preliminary</xsl:text>
         </xsl:if>
       </li>
      </ul>
    </xsl:otherwise>
   </xsl:choose>
  </div>
</xsl:template>

</xsl:stylesheet>
