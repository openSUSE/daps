<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:svg="http://www.w3.org/2000/svg">



<xsl:template match="xref" name="xref">
  <xsl:variable name="targets" select="key('id',@linkend)"/>
  <xsl:variable name="target" select="$targets[1]"/>
  <xsl:variable name="refelem" select="local-name($target)"/>
  <xsl:variable name="target.book" select="$target/ancestor-or-self::book"/>
  <xsl:variable name="this.book" select="ancestor-or-self::book"/>

<!-- <xsl:message>
 count(targets): <xsl:value-of select="count($targets)"/>
 target:         <xsl:value-of select="name($target)"/>
 refelem:        <xsl:value-of select="$refelem"/>
 ancestor:       <xsl:value-of select="$target.book/@condition"/>
 title:          <xsl:value-of select="$target.book/bookinfo/title"/>
.......................................
</xsl:message>-->

  <xsl:call-template name="check.id.unique">
    <xsl:with-param name="linkend" select="@linkend"/>
  </xsl:call-template>

  <xsl:choose>
    <xsl:when test="(generate-id($target.book) = generate-id($this.book)) or
                     not(/set) or /article">
      <!-- An xref that stays inside the current book; use the defaults -->
       <xsl:apply-imports/>
       <!--<xsl:call-template name="xref.old"/>-->
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="/set/@id=$rootid or
                        /article/@id=$rootid">
           <xsl:apply-imports/><!-- If we use the whole set, do the usual stuff -->
           <!-- <xsl:call-template name="xref.old"/> -->
        </xsl:when>
        <xsl:otherwise>
          <!-- A reference into another book -->
          <xsl:variable name="target.chapandapp" 
                        select="$target/ancestor-or-self::chapter[@lang!='']
                                | $target/ancestor-or-self::appendix[@lang!='']"/>
          
          <xsl:if test="$warn.xrefs.into.diff.lang != 0 and 
                        $target.chapandapp/@lang != $this.book/@lang">
            <xsl:message>WARNING: The xref '<xsl:value-of 
            select="@linkend"/>' points to a chapter (id='<xsl:value-of 
              select="$target.chapandapp/@id"/>') with a different language than the main book.</xsl:message>
          </xsl:if>
          
          <xsl:call-template name="create.linkto.other.book">
            <xsl:with-param name="target" select="$target"/>
          </xsl:call-template>
          
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="create.linkto.other.book">
  <xsl:param name="target"/>
  <xsl:variable name="refelem" select="local-name($target)"/>
  <xsl:variable name="target.book" select="($target/ancestor-or-self::article|$target/ancestor-or-self::book)[1]"/>
  <!--<xsl:param name=""/>-->
  <xsl:variable name="lang" select="ancestor-or-self::*/@lang"/>
  
  <xsl:if test="$lang != 'ko'"> 
    <xsl:apply-templates select="$target" mode="xref-to">
      <xsl:with-param name="referrer" select="."/>
      <xsl:with-param name="xrefstyle">
        <xsl:choose>
          <xsl:when test="$refelem = 'chapter' or
            $refelem = 'appendix'">number</xsl:when>
          <xsl:otherwise>nonumber</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:if>
  
  <xsl:text> (</xsl:text>
  <xsl:if test="$target/self::sect1 or
    $target/self::sect2 or
    $target/self::sect3 or
    $target/self::sect4">
    <xsl:variable name="hierarchy.node" 
      select="(
      $target/ancestor-or-self::chapter |
      $target/ancestor-or-self::appendix |
      $target/ancestor-or-self::preface)[1]"/>
    <xsl:if test="$hierarchy.node">
      <xsl:apply-templates select="$hierarchy.node"
      mode="xref-to">
      <xsl:with-param name="referrer" select="."/>
      <!--<xsl:with-param name="xrefstyle">select: labelnumber title</xsl:with-param>-->
      </xsl:apply-templates>
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:if>
  <xsl:text>&#x2191;</xsl:text>
  
  <xsl:choose>
    <xsl:when test="$refelem = 'article'">
      <xsl:apply-templates select="$target/title" mode="xref-to"/>
    </xsl:when>
    <xsl:when test="$refelem = 'book'">
      <xsl:apply-templates 
        select="$target.book" 
        mode="xref-to"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates 
        select="$target.book" 
        mode="xref-to"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>)</xsl:text>
  
  <xsl:if test="$lang = 'ko'"> 
    <xsl:apply-templates select="$target" mode="xref-to">
      <xsl:with-param name="referrer" select="."/>
      <xsl:with-param name="xrefstyle">
        <xsl:choose>
          <xsl:when test="$refelem = 'chapter' or
            $refelem = 'appendix'">number</xsl:when>
          <xsl:otherwise>nonumber</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:if>
</xsl:template>

<!--
  This template avoids the following error message:
  Request for title of element with no title: guimenu
-->
<xsl:template match="bridgehead/guimenu" mode="title.markup">
  <xsl:apply-templates />
</xsl:template>
  
</xsl:stylesheet>

