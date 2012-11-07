<?xml version="1.0"?>
<!-- 
  Purpose:
     Make the anchor template dysfunctional.
     
   See Also:
     * http://docbook.sourceforge.net/release/xsl/current/doc/html/index.html

   Author(s): Stefan Knorr <sknorr@suse.de>
   Copyright: 2012, Stefan Knorr

-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">


    <xsl:template name="anchor">
        <xsl:param name="node" select="."/>
        <xsl:param name="conditional" select="1"/>
        <xsl:if test="local-name($node) = 'figure'">
                    <xsl:attribute name="id">
                        <xsl:call-template name="object.id">
                            <xsl:with-param name="object" select="$node"/>
                        </xsl:call-template>
                    </xsl:attribute>
       </xsl:if>
        
        <!-- Elif: Sorry! -->
    </xsl:template>

</xsl:stylesheet>