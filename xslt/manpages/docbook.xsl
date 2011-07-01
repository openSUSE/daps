<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: docbook.xsl 18664 2007-03-19 12:32:29Z jjaeger $ -->
<xsl:stylesheet version="1.0"
    xmlns:exsl="http://exslt.org/common"
    xmlns:saxon="http://icl.com/saxon"
    xmlns:lxslt="http://xml.apache.org/xslt"
    xmlns:redirect="http://xml.apache.org/xalan/redirect"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    extension-element-prefixes="saxon redirect lxslt exsl">

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl"/>

<xsl:key   name="id" match="*" use="@id|@xml:id"/>


<xsl:param name="show.comments">0</xsl:param>
<xsl:param name="rootid"/>
<!--<xsl:param name="man.output.base.dir">./man/</xsl:param>-->
<xsl:param name="man.output.in.separate.dir" select="1"/>

<xsl:template match="remark">
  <xsl:if test="$show.comments != 0">
    <xsl:apply-imports/>
  </xsl:if>
</xsl:template>


<xsl:template name="write.chunk.toms">
  <xsl:param name="filename" select="''"/>
  <xsl:param name="quiet" select="$chunker.output.quiet"/>
  <xsl:param name="suppress-context-node-name" select="0"/>
  <xsl:param name="message-prolog"/>
  <xsl:param name="message-epilog"/>

  <xsl:param name="method" select="$chunker.output.method"/>
  <xsl:param name="encoding" select="$chunker.output.encoding"/>
  <xsl:param name="indent" select="$chunker.output.indent"/>
  <xsl:param name="omit-xml-declaration"
             select="$chunker.output.omit-xml-declaration"/>
  <xsl:param name="standalone" select="$chunker.output.standalone"/>
  <xsl:param name="doctype-public" select="$chunker.output.doctype-public"/>
  <xsl:param name="doctype-system" select="$chunker.output.doctype-system"/>
  <xsl:param name="media-type" select="$chunker.output.media-type"/>
  <xsl:param name="cdata-section-elements"
             select="$chunker.output.cdata-section-elements"/>

  <xsl:param name="content"/>

  <xsl:message>Filename: "<xsl:value-of select="$filename"/>"</xsl:message>

  <xsl:if test="$quiet = 0">
    <xsl:message>
      <xsl:if test="not($message-prolog = '')">
        <xsl:value-of select="$message-prolog"/>
      </xsl:if>
      <xsl:text>*** Writing </xsl:text>
      <xsl:value-of select="$filename"/>
      <xsl:if test="name(.) != '' and $suppress-context-node-name = 0">
        <xsl:text> for </xsl:text>
        <xsl:value-of select="name(.)"/>
        <xsl:if test="@id">
          <xsl:text>(</xsl:text>
          <xsl:value-of select="@id"/>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="not($message-epilog = '')">
        <xsl:value-of select="$message-epilog"/>
      </xsl:if>
    </xsl:message>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="element-available('exsl:document')">
      <xsl:choose>
        <!-- Handle the permutations ... -->
        <xsl:when test="$media-type != ''">
          <xsl:choose>
            <xsl:when test="$doctype-public != '' and $doctype-system != ''">
              <exsl:document href="{$filename}"
                             method="{$method}"
                             encoding="{$encoding}"
                             indent="{$indent}"
                             omit-xml-declaration="{$omit-xml-declaration}"
                             cdata-section-elements="{$cdata-section-elements}"
                             media-type="{$media-type}"
                             doctype-public="{$doctype-public}"
                             doctype-system="{$doctype-system}"
                             standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </exsl:document>
            </xsl:when>
            <xsl:when test="$doctype-public != '' and $doctype-system = ''">
              <exsl:document href="{$filename}"
                             method="{$method}"
                             encoding="{$encoding}"
                             indent="{$indent}"
                             omit-xml-declaration="{$omit-xml-declaration}"
                             cdata-section-elements="{$cdata-section-elements}"
                             media-type="{$media-type}"
                             doctype-public="{$doctype-public}"
                             standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </exsl:document>
            </xsl:when>
            <xsl:when test="$doctype-public = '' and $doctype-system != ''">
              <exsl:document href="{$filename}"
                             method="{$method}"
                             encoding="{$encoding}"
                             indent="{$indent}"
                             omit-xml-declaration="{$omit-xml-declaration}"
                             cdata-section-elements="{$cdata-section-elements}"
                             media-type="{$media-type}"
                             doctype-system="{$doctype-system}"
                             standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </exsl:document>
            </xsl:when>
            <xsl:otherwise><!-- $doctype-public = '' and $doctype-system = ''"> -->
              <exsl:document href="{$filename}"
                             method="{$method}"
                             encoding="{$encoding}"
                             indent="{$indent}"
                             omit-xml-declaration="{$omit-xml-declaration}"
                             cdata-section-elements="{$cdata-section-elements}"
                             media-type="{$media-type}"
                             standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </exsl:document>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$doctype-public != '' and $doctype-system != ''">
              <exsl:document href="{$filename}"
                             method="{$method}"
                             encoding="{$encoding}"
                             indent="{$indent}"
                             omit-xml-declaration="{$omit-xml-declaration}"
                             cdata-section-elements="{$cdata-section-elements}"
                             doctype-public="{$doctype-public}"
                             doctype-system="{$doctype-system}"
                             standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </exsl:document>
            </xsl:when>
            <xsl:when test="$doctype-public != '' and $doctype-system = ''">
              <exsl:document href="{$filename}"
                             method="{$method}"
                             encoding="{$encoding}"
                             indent="{$indent}"
                             omit-xml-declaration="{$omit-xml-declaration}"
                             cdata-section-elements="{$cdata-section-elements}"
                             doctype-public="{$doctype-public}"
                             standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </exsl:document>
            </xsl:when>
            <xsl:when test="$doctype-public = '' and $doctype-system != ''">
              <exsl:document href="{$filename}"
                             method="{$method}"
                             encoding="{$encoding}"
                             indent="{$indent}"
                             omit-xml-declaration="{$omit-xml-declaration}"
                             cdata-section-elements="{$cdata-section-elements}"
                             doctype-system="{$doctype-system}"
                             standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </exsl:document>
            </xsl:when>
            <xsl:otherwise><!-- $doctype-public = '' and $doctype-system = ''"> -->
              <exsl:document href="{$filename}"
                             method="{$method}"
                             encoding="{$encoding}"
                             indent="{$indent}"
                             omit-xml-declaration="{$omit-xml-declaration}"
                             cdata-section-elements="{$cdata-section-elements}"
                             standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </exsl:document>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:when test="element-available('saxon:output')">
      <xsl:choose>
        <!-- Handle the permutations ... -->
        <xsl:when test="$media-type != ''">
          <xsl:choose>
            <xsl:when test="$doctype-public != '' and $doctype-system != ''">
              <saxon:output saxon:character-representation="{$saxon.character.representation}"
                            href="{$filename}"
                            method="{$method}"
                            encoding="{$encoding}"
                            indent="{$indent}"
                            omit-xml-declaration="{$omit-xml-declaration}"
                            cdata-section-elements="{$cdata-section-elements}"
                            media-type="{$media-type}"
                            doctype-public="{$doctype-public}"
                            doctype-system="{$doctype-system}"
                            standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </saxon:output>
            </xsl:when>
            <xsl:when test="$doctype-public != '' and $doctype-system = ''">
              <saxon:output saxon:character-representation="{$saxon.character.representation}"
                            href="{$filename}"
                            method="{$method}"
                            encoding="{$encoding}"
                            indent="{$indent}"
                            omit-xml-declaration="{$omit-xml-declaration}"
                            cdata-section-elements="{$cdata-section-elements}"
                            media-type="{$media-type}"
                            doctype-public="{$doctype-public}"
                            standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </saxon:output>
            </xsl:when>
            <xsl:when test="$doctype-public = '' and $doctype-system != ''">
              <saxon:output saxon:character-representation="{$saxon.character.representation}"
                            href="{$filename}"
                            method="{$method}"
                            encoding="{$encoding}"
                            indent="{$indent}"
                            omit-xml-declaration="{$omit-xml-declaration}"
                            cdata-section-elements="{$cdata-section-elements}"
                            media-type="{$media-type}"
                            doctype-system="{$doctype-system}"
                            standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </saxon:output>
            </xsl:when>
            <xsl:otherwise><!-- $doctype-public = '' and $doctype-system = ''"> -->
              <saxon:output saxon:character-representation="{$saxon.character.representation}"
                            href="{$filename}"
                            method="{$method}"
                            encoding="{$encoding}"
                            indent="{$indent}"
                            omit-xml-declaration="{$omit-xml-declaration}"
                            cdata-section-elements="{$cdata-section-elements}"
                            media-type="{$media-type}"
                            standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </saxon:output>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$doctype-public != '' and $doctype-system != ''">
              <saxon:output saxon:character-representation="{$saxon.character.representation}"
                            href="{$filename}"
                            method="{$method}"
                            encoding="{$encoding}"
                            indent="{$indent}"
                            omit-xml-declaration="{$omit-xml-declaration}"
                            cdata-section-elements="{$cdata-section-elements}"
                            doctype-public="{$doctype-public}"
                            doctype-system="{$doctype-system}"
                            standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </saxon:output>
            </xsl:when>
            <xsl:when test="$doctype-public != '' and $doctype-system = ''">
              <saxon:output saxon:character-representation="{$saxon.character.representation}"
                            href="{$filename}"
                            method="{$method}"
                            encoding="{$encoding}"
                            indent="{$indent}"
                            omit-xml-declaration="{$omit-xml-declaration}"
                            cdata-section-elements="{$cdata-section-elements}"
                            doctype-public="{$doctype-public}"
                            standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </saxon:output>
            </xsl:when>
            <xsl:when test="$doctype-public = '' and $doctype-system != ''">
              <saxon:output saxon:character-representation="{$saxon.character.representation}"
                            href="{$filename}"
                            method="{$method}"
                            encoding="{$encoding}"
                            indent="{$indent}"
                            omit-xml-declaration="{$omit-xml-declaration}"
                            cdata-section-elements="{$cdata-section-elements}"
                            doctype-system="{$doctype-system}"
                            standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </saxon:output>
            </xsl:when>
            <xsl:otherwise><!-- $doctype-public = '' and $doctype-system = ''"> -->
              <saxon:output saxon:character-representation="{$saxon.character.representation}"
                            href="{$filename}"
                            method="{$method}"
                            encoding="{$encoding}"
                            indent="{$indent}"
                            omit-xml-declaration="{$omit-xml-declaration}"
                            cdata-section-elements="{$cdata-section-elements}"
                            standalone="{$standalone}">
                <xsl:copy-of select="$content"/>
              </saxon:output>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:when test="element-available('redirect:write')">
      <!-- Xalan uses redirect -->
      <redirect:write file="{$filename}">
        <xsl:copy-of select="$content"/>
      </redirect:write>
    </xsl:when>

    <xsl:otherwise>
      <!-- it doesn't matter since we won't be making chunks... -->
      <xsl:message terminate="yes">
        <xsl:text>Can't make chunks with </xsl:text>
        <xsl:value-of select="system-property('xsl:vendor')"/>
        <xsl:text>'s processor.</xsl:text>
      </xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="/">
  <xsl:choose>
    <xsl:when test="$rootid != ''">
      <xsl:choose>
        <xsl:when test="count(key('id',$rootid)) = 0">
          <xsl:message terminate="yes">
            <xsl:text>ID '</xsl:text>
            <xsl:value-of select="$rootid"/>
            <xsl:text>' not found in document.</xsl:text>
          </xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="key('id',$rootid)//refentry" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- omit copyright section -->  
  <xsl:template name="copyright.section"/>

<!--  don't print the product name and version -->
<!-- FIXME toms: we might need to put SOMETHING in there -->
<xsl:param name="refentry.source.name.profile.enabled">1</xsl:param>
<xsl:param name="refentry.source.name.profile">0</xsl:param>
<xsl:param name="refentry.version.profile.enabled">1</xsl:param>
<xsl:param name="refentry.version.profile">0</xsl:param>

<!-- put first step of a procedure on its own line -->
<xsl:template match="itemizedlist[ancestor::listitem or ancestor::step  or ancestor::glossdef]|
	             orderedlist[ancestor::listitem or ancestor::step or ancestor::glossdef]|
                     procedure[ancestor::listitem or ancestor::step or ancestor::glossdef]|procedure">
  <xsl:text>.RS</xsl:text> 
  <xsl:if test="not($list-indent = '')">
    <xsl:text> </xsl:text>
    <xsl:value-of select="$list-indent"/>
  </xsl:if>
  <xsl:text>&#10;</xsl:text>
  <xsl:if test="title">
    <xsl:text>.PP&#10;</xsl:text>
    <xsl:apply-templates mode="bold" select="title"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>
  <xsl:text>.TP</xsl:text> 
  <xsl:if test="not($list-indent = '')">
    <xsl:text> </xsl:text>
    <xsl:value-of select="$list-indent"/>
  </xsl:if>
  <xsl:text>&#10;</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>.RE&#10;</xsl:text>
  <xsl:if test="following-sibling::node() or
                parent::para[following-sibling::node()] or
                parent::simpara[following-sibling::node()] or
                parent::remark[following-sibling::node()]">
    <xsl:text>.IP ""</xsl:text> 
    <xsl:if test="not($list-indent = '')">
      <xsl:text> </xsl:text>
      <xsl:value-of select="$list-indent"/>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
