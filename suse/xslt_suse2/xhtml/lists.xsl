<?xml version="1.0" encoding="ASCII"?>
<!-- 
    Purpose:
    Add a wrapper div around procedures, so the title can be left-aligned while
    everything else in the procedure gets a little border on the left and thus
    is padded a bit more.
    
    Author(s): Thomas Schraitle <toms@opensuse.org>, Stefan Knorr <sknorr@suse.de>
    Copyright: 2012, Thomas Schraitle, Stefan Knorr
    
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="exsl">


    <xsl:template match="procedure">
                
        <!-- Preserve order of PIs and comments -->
        <xsl:variable name="preamble" 
            select="*[not(self::step                   
                      or self::title                   
                      or self::titleabbrev)]      
                      |comment()[not(preceding-sibling::step)]
                      |processing-instruction()[not(preceding-sibling::step)]"/>
        
        <div>
            <xsl:call-template name="common.html.attributes"/>
            <xsl:call-template name="id.attribute">
                <xsl:with-param name="conditional">
                    <xsl:choose>
                        <xsl:when test="title">0</xsl:when>
                        <xsl:otherwise>1</xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="anchor">
                <xsl:with-param name="conditional">
                    <xsl:choose>
                        <xsl:when test="title">0</xsl:when>
                        <xsl:otherwise>1</xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
            
            <xsl:if test="(title or info/title)">
                <xsl:call-template name="formal.object.heading"/>
            </xsl:if>
            <div class="procedure-contents">
            <xsl:apply-templates select="$preamble"/>
            
            <xsl:choose>
                <xsl:when test="count(step) = 1">
                    <ul>
                        <xsl:call-template name="generate.class.attribute"/>
                        <xsl:apply-templates select="step
                                                     |comment()[preceding-sibling::step]
                                                     |processing-instruction()[preceding-sibling::step]"/>
                    </ul>
                </xsl:when>
                <xsl:otherwise>
                    <ol>
                        <xsl:call-template name="generate.class.attribute"/>
                        <xsl:attribute name="type">
                            <xsl:value-of select="substring($procedure.step.numeration.formats,1,1)"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="step
                                                     |comment()[preceding-sibling::step]
                                                     |processing-instruction()[preceding-sibling::step]"/>
                    </ol>
                </xsl:otherwise>
            </xsl:choose>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>
