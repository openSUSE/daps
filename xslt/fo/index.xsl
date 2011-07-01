<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet 
[
<!ENTITY primaryie      'primaryie/phrase[not(@role)]'>
<!ENTITY secondaryie  'secondaryie/phrase[not(@role)]'>
<!ENTITY tertiaryie       'tertiaryie/phrase[not(@role)]'>
]>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:rx="http://www.renderx.com/XSL/Extensions"
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl"
    exclude-result-prefixes="exsl">

    <xsl:template match="book/index">
        <xsl:choose>
            <xsl:when test="$indexfile != ''">
                <xsl:variable name="indexnodes"
                    select="document($indexfile, .)" />
                <xsl:message>indexnodes: '<xsl:value-of
                        select="name($indexnodes/*)" />'</xsl:message>
                <xsl:choose>
                    <xsl:when test="$indexnodes">
                        <xsl:message>Incorporating index... </xsl:message>
                        <xsl:call-template name="make-index">
                            <xsl:with-param name="node" select="$indexnodes/*"
                             />
                        </xsl:call-template>
                        <xsl:message>
                            <xsl:text>Incorporating index was successful.</xsl:text>
                        </xsl:message>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>Warning: Unable to process index file
                                '<xsl:value-of select="$indexfile"
                         />'.</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-imports />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="make-index">
        <xsl:param name="node" />
        <xsl:variable name="id">
            <xsl:call-template name="object.id" />
        </xsl:variable>

        <xsl:if test="$generate.index != 0">
            <xsl:variable name="master-reference">
                <xsl:call-template name="select.pagemaster">
                    <xsl:with-param name="pageclass">
                        <xsl:if test="$make.index.markup != 0">body</xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:variable>
            <fo:page-sequence hyphenate="{$hyphenate}"
                id="my-index-page-sequence"
                master-reference="{$master-reference}">
                <xsl:attribute name="language">
                    <xsl:call-template name="l10n.language" />
                </xsl:attribute>
                <xsl:attribute name="format">
                    <xsl:call-template name="page.number.format">
                        <xsl:with-param name="master-reference"
                            select="$master-reference" />
                    </xsl:call-template>
                </xsl:attribute>

                <xsl:attribute name="initial-page-number">
                    <xsl:call-template name="initial.page.number">
                        <xsl:with-param name="master-reference"
                            select="$master-reference" />
                    </xsl:call-template>
                </xsl:attribute>

                <xsl:attribute name="force-page-count">
                    <xsl:call-template name="force.page.count">
                        <xsl:with-param name="master-reference"
                            select="$master-reference" />
                    </xsl:call-template>
                </xsl:attribute>

                <xsl:attribute name="hyphenation-character">
                    <xsl:call-template name="gentext">
                        <xsl:with-param name="key"
                            select="'hyphenation-character'" />
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:attribute name="hyphenation-push-character-count">
                    <xsl:call-template name="gentext">
                        <xsl:with-param name="key"
                            select="'hyphenation-push-character-count'" />
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:attribute name="hyphenation-remain-character-count">
                    <xsl:call-template name="gentext">
                        <xsl:with-param name="key"
                            select="'hyphenation-remain-character-count'" />
                    </xsl:call-template>
                </xsl:attribute>

                <xsl:apply-templates select="$node" mode="running.head.mode">
                    <xsl:with-param name="master-reference"
                        select="$master-reference" />
                </xsl:apply-templates>
                <xsl:apply-templates select="$node" mode="running.foot.mode">
                    <xsl:with-param name="master-reference"
                        select="$master-reference" />
                </xsl:apply-templates>

                <fo:flow flow-name="xsl-region-body">
                    <xsl:call-template name="set.flow.properties">
                        <xsl:with-param name="element"
                            select="local-name($node)" />
                        <xsl:with-param name="master-reference"
                            select="$master-reference" />
                    </xsl:call-template>

                    <fo:block span="all"
                        xsl:use-attribute-sets="index.titlepage.recto.style component.title.properties"
                        margin-left="0pt" font-size="24.8832pt"
                        font-family="{$title.fontset}" font-weight="bold">
                        <xsl:choose>
                            <xsl:when test="$node/title != ''">
                                <xsl:value-of select="$node/*[1]" />
                            </xsl:when>
                            <xsl:otherwise>
                                <!--FIXME: <xsl:call-template name="" />-->
                                <xsl:value-of select="$node/title" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                    <fo:block id="{$id}">
                        <xsl:call-template name="index.titlepage">
                            <xsl:with-param name="node" select="$node" />
                        </xsl:call-template>
                    </fo:block>
                    <xsl:apply-templates select="$node" />
                    <!-- !!! -->
                    <xsl:if
                        test="count(indexentry) = 0 and count(indexdiv) = 0">
                        <xsl:choose>
                            <xsl:when test="$make.index.markup != 0">
                                <fo:block wrap-option="no-wrap"
                                    white-space-collapse="false"
                                    xsl:use-attribute-sets="monospace.verbatim.properties"
                                    linefeed-treatment="preserve">
                                    <xsl:call-template
                                       name="generate-index-markup">
                                       <xsl:with-param name="scope"
                                       select="(ancestor::book|/)[last()]"
                                        />
                                    </xsl:call-template>
                                </fo:block>
                            </xsl:when>
                            <xsl:when test="indexentry|indexdiv/indexentry">
                                <xsl:apply-templates select="$node" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="generate-index">
                                    <xsl:with-param name="scope"
                                       select="(ancestor::book|/)[last()]" />
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </fo:flow>
            </fo:page-sequence>
        </xsl:if>
    </xsl:template>

    <!-- Handling of  -->

    <xsl:template match="indexentryie">
        <xsl:variable name="refs" select="." />

        <fo:block>
            <xsl:apply-templates
                select="primaryie|secondaryie|tertiaryie|seealsoie"/>
        </fo:block>
    </xsl:template>

    <xsl:template match="primaryie/phrase[@role]|secondaryie/phrase[@role]" />

    <xsl:template match="primaryie">
        <xsl:variable name="term.separator">
            <xsl:call-template name="index.separator">
                <xsl:with-param name="key" select="'index.term.separator'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="range.separator">
            <xsl:call-template name="index.separator">
                <xsl:with-param name="key" select="'index.range.separator'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="number.separator">
            <xsl:call-template name="index.separator">
                <xsl:with-param name="key" select="'index.number.separator'"
                 />
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="primary" select="phrase[not(@role)]" />


        <fo:block>
            <xsl:value-of select="$primary" />
            <!--<fo:inline>, /</fo:inline>-->
            <xsl:copy-of select="$term.separator" />
            <xsl:variable name="primary.significant"
                select="concat($primary, $significant.flag)" />
            <rx:page-index list-separator="{$number.separator}"
                range-separator="{$range.separator}">
                <xsl:if test="@significance='preferred'">
                    <rx:index-item
                        xsl:use-attribute-sets="index.preferred.page.properties xep.index.item.properties"
                        ref-key="{$primary.significant}" />
                </xsl:if>
                <xsl:if
                    test="not(@significance) or @significance!='preferred'">
                    <rx:index-item
                        xsl:use-attribute-sets="xep.index.item.properties"
                        ref-key="{$primary}" />
                </xsl:if>
            </rx:page-index>
            <xsl:if test="following-sibling::seeie">
                <xsl:text> (</xsl:text>
                <xsl:call-template name="gentext">
                    <xsl:with-param name="key" select="'see'" />
                </xsl:call-template>
                <xsl:text> </xsl:text>
                <xsl:apply-templates select="following-sibling::seeie" />
                <xsl:text>)</xsl:text>
            </xsl:if>
        </fo:block>
    </xsl:template>

    <xsl:template match="secondaryie">
        <xsl:variable name="term.separator">
            <xsl:call-template name="index.separator">
                <xsl:with-param name="key" select="'index.term.separator'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="range.separator">
            <xsl:call-template name="index.separator">
                <xsl:with-param name="key" select="'index.range.separator'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="number.separator">
            <xsl:call-template name="index.separator">
                <xsl:with-param name="key" select="'index.number.separator'"
                 />
            </xsl:call-template>
        </xsl:variable>

        
        <xsl:variable name="key">
            <xsl:value-of select="../&primaryie;" />
            <xsl:if test="@significance='preferred'">
                <xsl:value-of select="$significant.flag" />
            </xsl:if>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="phrase[not(@role)]" />
        </xsl:variable>

        <fo:block start-indent="1pc">
            <xsl:value-of select="phrase[not(@role)]" />
            <xsl:copy-of select="$term.separator" />
            <rx:page-index list-separator="{$number.separator}"
                range-separator="{$range.separator}">
                <rx:index-item
                    xsl:use-attribute-sets="xep.index.item.properties"
                    ref-key="{$key}" />
            </rx:page-index>
        </fo:block>
    </xsl:template>

    <xsl:template match="tertiaryie">
        <xsl:variable name="term.separator">
            <xsl:call-template name="index.separator">
                <xsl:with-param name="key" select="'index.term.separator'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="range.separator">
            <xsl:call-template name="index.separator">
                <xsl:with-param name="key" select="'index.range.separator'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="number.separator">
            <xsl:call-template name="index.separator">
                <xsl:with-param name="key" select="'index.number.separator'"
                 />
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="key" select="phrase[@role='key'][1]"/>

        <fo:block start-indent="2pc">
            <xsl:value-of select="phrase[not(@role)]" />
            <xsl:copy-of select="$term.separator" />
            <rx:page-index list-separator="{$number.separator}"
                range-separator="{$range.separator}">
                <rx:index-item
                    xsl:use-attribute-sets="xep.index.item.properties"
                    ref-key="{$key}" />
            </rx:page-index>
        </fo:block>
    </xsl:template>


    <xsl:template match="primaryie/phrase|secondaryie/phrase">
        <fo:inline>
            <xsl:apply-templates />
        </fo:inline>
    </xsl:template>

    <!--  Titlepages -->
    <xsl:template name="index.titlepage">
        <xsl:param name="node" select="." />
        <!--<xsl:message>index.titlepage</xsl:message>-->
        <fo:block>
            <xsl:variable name="recto.content">
                <xsl:call-template name="index.titlepage.before.recto">
                    <xsl:with-param name="node" select="$node" />
                </xsl:call-template>
                <xsl:call-template name="index.titlepage.recto">
                    <xsl:with-param name="node" select="$node" />
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="recto.elements.count">
                <xsl:choose>
                    <xsl:when test="function-available('exsl:node-set')">
                        <xsl:value-of
                            select="count(exsl:node-set($recto.content)/*)" />
                    </xsl:when>
                    <xsl:when
                        test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                        <!--Xalan quirk-->
                        <xsl:value-of
                            select="count(exsl:node-set($recto.content)/*)" />
                    </xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if
                test="(normalize-space($recto.content) != '') or ($recto.elements.count &gt; 0)">
                <fo:block>
                    <xsl:copy-of select="$recto.content" />
                </fo:block>
            </xsl:if>
            <xsl:variable name="verso.content">
                <xsl:call-template name="index.titlepage.before.verso" />
                <xsl:call-template name="index.titlepage.verso" />
            </xsl:variable>
            <xsl:variable name="verso.elements.count">
                <xsl:choose>
                    <xsl:when test="function-available('exsl:node-set')">
                        <xsl:value-of
                            select="count(exsl:node-set($verso.content)/*)" />
                    </xsl:when>
                    <xsl:when
                        test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
                        <!--Xalan quirk-->
                        <xsl:value-of
                            select="count(exsl:node-set($verso.content)/*)" />
                    </xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if
                test="(normalize-space($verso.content) != '') or ($verso.elements.count &gt; 0)">
                <fo:block>
                    <xsl:copy-of select="$verso.content" />
                </fo:block>
            </xsl:if>
            <xsl:call-template name="index.titlepage.separator" />
        </fo:block>
    </xsl:template>

    <xsl:template name="index.titlepage.recto">
        <xsl:param name="node" select="." />
        <!--<xsl:message>index.titlepage.recto</xsl:message>
-->
        
        <xsl:choose>
          <xsl:when test="$indexfile != ''">
            <!-- Moved generation of title to make-index to span over -->  
          </xsl:when>          
          <xsl:otherwise>
            <!-- Normal title generation -->
            <fo:block xsl:use-attribute-sets="index.titlepage.recto.style" 
              margin-left="0pt" 
              role="index-title"
              font-size="24.8832pt" 
              font-family="{$title.fontset}" 
              font-weight="bold">
              <xsl:call-template name="component.title">
                <xsl:with-param name="node" select="ancestor-or-self::index[1]"/>
                <xsl:with-param name="pagewide" select="1"/>
              </xsl:call-template>
            </fo:block>
          </xsl:otherwise>
        </xsl:choose>
      
        <xsl:choose>
            <xsl:when test="indexinfo/subtitle">
                <xsl:apply-templates mode="index.titlepage.recto.auto.mode"
                    select="$node/indexinfo/subtitle" />
            </xsl:when>
            <xsl:when test="docinfo/subtitle">
                <xsl:apply-templates mode="index.titlepage.recto.auto.mode"
                    select="$node/docinfo/subtitle" />
            </xsl:when>
            <xsl:when test="info/subtitle">
                <xsl:apply-templates mode="index.titlepage.recto.auto.mode"
                    select="$node/info/subtitle" />
            </xsl:when>
            <xsl:when test="subtitle">
                <xsl:apply-templates mode="index.titlepage.recto.auto.mode"
                    select="$node/subtitle" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="indexdiv.titlepage.recto">
        <xsl:param name="node" select="." />
        <xsl:message> indexdiv.titlepage.recto: <xsl:value-of
                select="$node/title" /></xsl:message>

        <fo:block xsl:use-attribute-sets="indexdiv.titlepage.recto.style">
            <xsl:call-template name="indexdiv.title">
                <xsl:with-param name="title" select="$node/title" />
            </xsl:call-template>
        </fo:block>
        <xsl:choose>
            <xsl:when test="indexdivinfo/subtitle">
                <xsl:apply-templates mode="indexdiv.titlepage.recto.auto.mode"
                    select="$node/indexdivinfo/subtitle" />
            </xsl:when>
            <xsl:when test="docinfo/subtitle">
                <xsl:apply-templates mode="indexdiv.titlepage.recto.auto.mode"
                    select="$node/docinfo/subtitle" />
            </xsl:when>
            <xsl:when test="info/subtitle">
                <xsl:apply-templates mode="indexdiv.titlepage.recto.auto.mode"
                    select="$node/info/subtitle" />
            </xsl:when>
            <xsl:when test="subtitle">
                <xsl:apply-templates mode="indexdiv.titlepage.recto.auto.mode"
                    select="$node/subtitle" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
