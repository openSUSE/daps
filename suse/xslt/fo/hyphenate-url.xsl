<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: hyphenate-url.xsl 43839 2009-08-31 14:50:03Z toms $ -->
<!DOCTYPE xsl:stylesheet >
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">

<!-- 
 Template hyphenate-url: Prepare URL to be hyphenated

 Parameters:
 * url: The respective URL
 * removestartslash: Remove a start slash, if available?
 * removeendslash:   Remove the trailing slash, if available?
 * insertendslash:   Insert a slash at the end of the hyphenated URL?
-->
<xsl:template name="hyphenate-url">
  <xsl:param name="url" select="''"/>
  <xsl:param name="removestartslash" select="true()"/>
  <xsl:param name="removeendslash" select="true()"/>
  <xsl:param name="insertendslash" select="false()"/>
  
  <xsl:variable name="normalurl" select="normalize-space($url)"/>

  <!-- 
    The variables A and B can only hold 0 (zero) or 1. These are precalculated
    indices for start (A) and end (B), used by the substring function.
    This is used to avoid nasty linebreaks between a text and a '/'
    character when the URL touches almost the right text margin.
  -->
  <xsl:variable name="A" select="starts-with($url, '/') and
    $removestartslash and $normalurl != '/'"/>
  <xsl:variable name="B" select="(substring($url, string-length($url), 1) = '/') 
                                  and $removeendslash and $normalurl != '/'"/>
  <xsl:variable name="len" select="string-length($normalurl)"/>
  

<!--  <xsl:message> hyphenate-url:
    url = '<xsl:value-of select="$normalurl"/>'
    len = <xsl:value-of select="string-length($normalurl)"/>
    A   = '<xsl:value-of select="$A"/>'
    B   = '<xsl:value-of select="$B"/>'
    
    removestartslash = '<xsl:value-of select="$removestartslash"/>'
    C   = <xsl:value-of select="string-length($normalurl) - $A - $B"/>
    start-with= '<xsl:value-of select="starts-with($url, '/')"/>'
    firstchar = '<xsl:value-of select="substring($normalurl, 1,1 )"/>'
    lastchar  = '<xsl:value-of select="substring($normalurl,
      string-length($normalurl), 1)"/>'
    substring = '<xsl:value-of select="substring($normalurl, $A +1,
      $len - $A - $B)"/>'
    substring3 = '<xsl:value-of select="substring($normalurl, 
      string-length(substring-before($normalurl, '://'))+4,
      $len - string-length(
         substring-before($normalurl, '://'))+3 - $B)"/>'
  </xsl:message>-->

  
    <xsl:choose>
      <!-- Don't use the hyphenation algorithm at all, if
           ulink.hyphenate is empty
      -->
      <xsl:when test="$ulink.hyphenate = '' or $fop1.extensions != 0">
        <xsl:value-of select="$normalurl"/>
      </xsl:when>

     <!-- This is only executed, when you have something like "smb://".
      If you skip this test, you get "smb:///" in the output.
     -->
     <xsl:when test="contains($normalurl, '://') and 
      (string-length($normalurl) - 
      string-length(substring-before($normalurl,'://')))
      = 3
      ">
      <xsl:copy-of select="$normalurl"/>
     </xsl:when>
     

      <!-- Remove the "SCHEMA://" prefix, so it does not disturbs the
      algorithm in "hyphenate-url-string" -->
      <xsl:when test="contains($normalurl, '://')">
        <xsl:variable name="schema" select="substring-before($normalurl,'://')"/>
        <xsl:variable name="core" select="substring($normalurl, 
                    string-length(substring-before($normalurl, '://'))+4,
                    $len - string-length($schema) -3 - $B)"/>        
        <xsl:value-of select="$schema"/>
        <xsl:text>://</xsl:text>
        <xsl:copy-of select="$ulink.hyphenate"/>
        <xsl:call-template name="hyphenate-url-string">
          <xsl:with-param name="url" select="$core"/>
        </xsl:call-template>
        <xsl:if test="$B or $insertendslash">
          <xsl:text>/</xsl:text>
        </xsl:if>
      </xsl:when>
      
      <xsl:otherwise>
        <xsl:if test="$A">
          <xsl:text>/</xsl:text>
        </xsl:if>
        <xsl:call-template name="hyphenate-url-string">
          <xsl:with-param name="url"
            select="substring($normalurl, 
                              $A +1,
                              string-length($normalurl) - $A - $B)"/>
        </xsl:call-template>
        <xsl:if test="$B">
          <xsl:text>/</xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- 
 Template hyphenate-url-string: Hyphenate URL
 
 Parameter:
 * url: The URL, removed from schemas like http://, ftp://, etc. and
        a trailing slash
-->
<xsl:template name="hyphenate-url-string">
  <xsl:param name="url" select="''"/>
  <xsl:variable name="char" select="substring($url,1,1)"/>

  <xsl:choose>
   <xsl:when test="$url=''"/>

   <!-- Insert breakpoint _before_ the character -->
   <xsl:when test="contains($ulink.hyphenate.before.chars, $char)">
     <xsl:value-of select="concat($ulink.hyphenate, $char)"/>
     <xsl:call-template name="hyphenate-url-string">
       <xsl:with-param name="url" select="substring($url, 2)"/>
     </xsl:call-template>
   </xsl:when>

   <!-- Insert breakpoint _after_ the character -->
   <xsl:when test="contains($ulink.hyphenate.after.chars, $char)">
     <xsl:value-of select="concat($char, $ulink.hyphenate)"/>
     <xsl:call-template name="hyphenate-url-string">
       <xsl:with-param name="url" select="substring($url, 2)"/>
     </xsl:call-template>
   </xsl:when>

   <xsl:otherwise>
     <xsl:value-of select="$char"/>
     <xsl:call-template name="hyphenate-url-string">
       <xsl:with-param name="url" select="substring($url, 2)"/>
     </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- ==================================================================== -->
<xsl:template match="filename" mode="hyphenate-url">
  <xsl:apply-templates mode="hyphenate-url"/>
</xsl:template>


<xsl:template match="text()" mode="hyphenate-url">
  <xsl:call-template name="hyphenate-url">
   <xsl:with-param name="url" select="."/>
  </xsl:call-template>
</xsl:template>


<xsl:template match="text()[preceding-sibling::replaceable]" mode="hyphenate-url">
 <xsl:call-template name="hyphenate-url">
   <xsl:with-param name="url" select="."/>
   <xsl:with-param name="removestartslash" select="false()"/>
 </xsl:call-template>
</xsl:template>


<xsl:template match="replaceable" mode="hyphenate-url">
 <xsl:call-template name="inline.italicseq">
   <xsl:with-param name="content">
     <xsl:call-template name="hyphenate-url">
       <xsl:with-param name="url">
        <xsl:apply-templates mode="hyphenate-url"/>
       </xsl:with-param>
     </xsl:call-template>
   </xsl:with-param>
 </xsl:call-template>
</xsl:template>


</xsl:stylesheet>
