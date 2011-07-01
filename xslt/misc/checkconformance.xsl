<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: checkconformance.xsl 9910 2006-05-19 15:15:19Z toms $ -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    
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
    
    <xsl:template match="set">
        <xsl:if test="not(@id)">
            <xsl:call-template name="hint.message">
                <xsl:with-param name="text">
                    <xsl:text>Missing @id attribute!</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="not(@lang)">
            <xsl:call-template name="hint.message">
                <xsl:with-param name="text">
                    <xsl:text>Missing @lang attribute!</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="book">
        <xsl:if test="not(@id)">
            <xsl:call-template name="hint.message">
                <xsl:with-param name="text">
                    <xsl:text>Missing @id attribute!</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="not(@lang)">
            <xsl:call-template name="hint.message">
                <xsl:with-param name="text">
                    <xsl:text>Missing @lang attribute!</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="appendix|chapter|part|preface|sect1|sect2|sect3|sect4">
        <xsl:choose>
            <xsl:when test="@id"/>
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
    
    <xsl:template match="example|figure|table">
        <xsl:choose>
            <xsl:when test="@id"/>
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
    
    <xsl:template match="informalfigure|informaltable">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="para|filename|systemitem|emphasis">
        <xsl:apply-templates/>
    </xsl:template>
        
    <xsl:template match="title"/>
    
    <xsl:template match="mediaobject">
        <xsl:if test="count(imageobject) != 2">
            <xsl:call-template name="error.message">
                <xsl:with-param name="text">mediaobject does not contain 2 imageobjects</xsl:with-param>
                <xsl:with-param name="withtitle" select="ancestor::figure"></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="procedure">
        <xsl:if test="not(title)">
            <xsl:call-template name="note.message">
                <xsl:with-param name="text">
                    <xsl:text>No title found</xsl:text>
                    <xsl:if test="@id">
                        <xsl:text> for </xsl:text>
                        <xsl:value-of select="@id"/>
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="step">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="indexterm|primary|secondary|tertiary"/>
    
    
    <xsl:template match="note|tip|caution|warning">
        <xsl:if test="not(title)">
           <xsl:call-template name="note.message">
                <xsl:with-param name="text">
                    <xsl:text>Recommended title not found</xsl:text>
                </xsl:with-param>
            </xsl:call-template> 
        </xsl:if>
    </xsl:template>
    
<!-- **************************************************************** -->
    <!-- Inline Elements -->
    <xsl:template match="command|systemitem|guimenu|menuchoice|literal"/>
    
    
</xsl:stylesheet>
