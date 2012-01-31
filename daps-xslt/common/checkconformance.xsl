<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Checks some conformance/consistency rules which can not be 
     done through DTD validation (aka "business rules")
     
   Parameters:
     None
       
   Input:
     Normal DocBook document
     
   Output:
     Debug messages
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle
   
-->

<xsl:stylesheet version="1.0"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    
<!-- **************************************************************** -->
    <xsl:template match="*">
        <xsl:call-template name="warning.message">
            <xsl:with-param name="text">
                <xsl:text>Unknown element</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="text()"/><!-- Empty, we are not interested in text nodes-->
    
<!-- **************************************************************** -->
    <xsl:template name="message">
        <xsl:param name="keyword"/>
        <xsl:param name="text"/>
        <xsl:param name="withname" select="true()"/>
        <xsl:param name="withtitle" select="title"/>
        
        <xsl:message>
            <xsl:value-of select="$keyword"/>
            <xsl:if test="$withname">
                <xsl:text>(</xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text>): </xsl:text>
            </xsl:if>
            <xsl:if test="$withtitle">
                <xsl:text>title=»</xsl:text>
                <xsl:value-of select="normalize-space($withtitle)"/>
                <xsl:text>«&#10;  </xsl:text>
            </xsl:if>
            <xsl:value-of select="$text"/>
        </xsl:message>
    </xsl:template>
    
    <xsl:template name="hint.message">
        <xsl:param name="text"/>
        <xsl:param name="withname" select="true()"/>
        <xsl:param name="withtitle" select="title"/>
        
        <xsl:call-template name="message">
            <xsl:with-param name="keyword">Hint</xsl:with-param>
            <xsl:with-param name="withtitle" select="$withtitle"/>
            <xsl:with-param name="text" select="$text"/>
            <xsl:with-param name="withname" select="$withname"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="error.message">
        <xsl:param name="text"/>
        <xsl:param name="withname" select="true()"/>
        <xsl:param name="withtitle" select="title"/>
        
        <xsl:call-template name="message">
            <xsl:with-param name="keyword">*** ERROR</xsl:with-param>
            <xsl:with-param name="withtitle" select="$withtitle"/>
            <xsl:with-param name="text" select="$text"/>
            <xsl:with-param name="withname" select="$withname"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="note.message">
        <xsl:param name="text"/>
        <xsl:param name="withname" select="true()"/>
        <xsl:param name="withtitle" select="title"/>
        
        <xsl:call-template name="message">
            <xsl:with-param name="keyword">Note</xsl:with-param>
            <xsl:with-param name="withtitle" select="$withtitle"/>
            <xsl:with-param name="text" select="$text"/>
            <xsl:with-param name="withname" select="$withname"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="warning.message">
        <xsl:param name="text"/>
        <xsl:param name="withname" select="true()"/>
        <xsl:param name="withtitle" select="title"/>
        
        <xsl:call-template name="message">
            <xsl:with-param name="keyword">* WARNING</xsl:with-param>
            <xsl:with-param name="withtitle" select="$withtitle"/>
            <xsl:with-param name="text" select="$text"/>
            <xsl:with-param name="withname" select="$withname"/>
        </xsl:call-template>
    </xsl:template>
    
    
<!-- **************************************************************** -->
    <xsl:template match="/">
        <xsl:if test="not(processing-instruction('xml-stylesheet'))">
            <xsl:call-template name="hint.message">
                <xsl:with-param name="text">
                    <xsl:text>Missing PI xml-stylesheet!</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:message>Done!</xsl:message>
    </xsl:template>
    
    <xsl:template match="set|db:set">
        <xsl:if test="not(@id) or not(@xml:id)">
            <xsl:call-template name="hint.message">
                <xsl:with-param name="text">
                    <xsl:text>Missing @id attribute!</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="not(@lang) or not(@xml:lang)">
            <xsl:call-template name="hint.message">
                <xsl:with-param name="text">
                    <xsl:text>Missing @lang attribute!</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="book|db:book">
        <xsl:if test="not(@id) or not(@xml:id)">
            <xsl:call-template name="hint.message">
                <xsl:with-param name="text">
                    <xsl:text>Missing @id attribute!</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="not(@lang) or not(@xml:lang)">
            <xsl:call-template name="hint.message">
                <xsl:with-param name="text">
                    <xsl:text>Missing @lang attribute!</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="appendix|db:appendix|
                         chapter|db:chapter|
                         part|db:part|
                         preface|db:preface|
                         sect1|db:sect1|
                         sect2|db:sect2|
                         sect3|db:sect3|
                         sect4|db:sect4">
        <xsl:choose>
            <xsl:when test="@id or @xml:id"/>
            <xsl:otherwise>
                <xsl:call-template name="hint.message">
                    <xsl:with-param name="text">
                        <xsl:text>There is no @id attribute.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="example|db:example|figure|db:figure|table|db:table">
        <xsl:choose>
            <xsl:when test="@id or @xml:id"/>
            <xsl:otherwise>
                <xsl:call-template name="hint.message">
                    <xsl:with-param name="text">
                        <xsl:text>There is no @id attribute.</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="informalfigure|db:informalfigure|informaltable|db:informaltable">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template  match="para|db:para|
                          filename|db:filename|
                          systemitem|db:systemitem|
                          emphasis|db:emphasis">
        <xsl:apply-templates/>
    </xsl:template>
        
    <xsl:template match="title|db:title"/>
    
    <xsl:template match="mediaobject|db:mediaobject">
        <xsl:if test="count(imageobject) != 2 or 
                      count(db:imageobject) != 2">
            <xsl:call-template name="error.message">
                <xsl:with-param name="text">mediaobject does not contain 2 imageobjects</xsl:with-param>
                <xsl:with-param name="withtitle"  select="(ancestor::figure|ancestor::db:figure)[1]"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="procedure|db:procedure">
        <xsl:if test="not(title) or not(db:title)">
            <xsl:call-template name="note.message">
                <xsl:with-param name="text">
                    <xsl:text>No title found</xsl:text>
                    <xsl:if test="@id or @xml:id">
                        <xsl:text> for </xsl:text>
                        <xsl:value-of select="(@id|@xml:id)[1]"/>
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="step|db:step">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="indexterm|db:indexterm|
                         primary|db:primary|
                         secondary|db:secondary|
                         tertiary|db:tertiary"/>
    
    
    <xsl:template  match="note|db:note|tip|db:tip|caution|db:caution|warning|db:warning">
        <xsl:if test="not(title) or not(db:title)">
           <xsl:call-template name="note.message">
                <xsl:with-param name="text">
                    <xsl:text>Recommended title not found</xsl:text>
                </xsl:with-param>
            </xsl:call-template> 
        </xsl:if>
    </xsl:template>
    
<!-- **************************************************************** -->
    <!-- Inline Elements -->
    <xsl:template match="command|db:command|
                         systemitem|db:systemitem|
                         guimenu|db:guimenu|
                         menuchoice|db:menuchoice|
                         literal|db:literal"/>
    
</xsl:stylesheet>
