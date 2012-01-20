<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: $ -->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


    <xsl:template match="table">
        <xsl:text>&#10;{|</xsl:text>
        <xsl:value-of select="$table.style"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>|}&#10;&#10;</xsl:text>
    </xsl:template>
    
    <xsl:template match="informaltable">
        <xsl:text>&#10;{|</xsl:text>
        <xsl:value-of select="$table.style"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>|}&#10;&#10;</xsl:text>        
    </xsl:template>
    
    <xsl:template match="table/title">
        <xsl:variable name="heading">
            <xsl:call-template name="inline.boldseq">
                <xsl:with-param name="contents">
                    <xsl:text>Table: </xsl:text>
                    
                    <xsl:apply-templates/>
                </xsl:with-param>
            </xsl:call-template>            
        </xsl:variable>
        
        <xsl:text>|+</xsl:text>
        <xsl:value-of select="normalize-space($heading)"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    
    <xsl:template match="table/title/text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

    <xsl:template match="colspec"/>
    
    <xsl:template match="tgroup">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tbody">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="thead|tfoot">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="thead/row|tfoot/row">
        <xsl:text>! </xsl:text>
        <xsl:value-of select="$table.header.style"/>
        <xsl:text> | </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="thead/row/entry">
        <xsl:if test="ancestor::colspec/@colwidth"></xsl:if>
        <xsl:if test="preceding-sibling::entry">
            <xsl:text> !! </xsl:text>
            <xsl:value-of select="$table.header.style"/>
            <xsl:text> | </xsl:text>
        </xsl:if>   
        <xsl:apply-templates/>
        <xsl:if test="not(following-sibling::entry)">
            <xsl:text>&#10;</xsl:text>    
        </xsl:if>        
    </xsl:template>
        
    <xsl:template match="row">
        <xsl:text>|-&#10;</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="entry">
        <xsl:variable name="contents">
            <xsl:apply-templates/>    
        </xsl:variable>
        <xsl:text>| </xsl:text>
        <xsl:if test="$table.entry.style != '' and ../following-sibling::row">
            <xsl:value-of select="$table.entry.style"/>
            <xsl:text> | </xsl:text>
        </xsl:if>
        <xsl:value-of select="normalize-space($contents)"/>
        <xsl:text>&#10;</xsl:text> 
    </xsl:template>
    
    <xsl:template match="entry/para">
        <xsl:call-template name="para"/>
    </xsl:template>

</xsl:stylesheet>
