<?xml version="1.0" encoding="UTF-8"?>
<!--
  Fix screens with prompt

  Purpose:
    This stylesheet fixes unfortunate linebreaks between a <screen> and a <prompt> tag

   <screen>
        <prompt>&gt; </prompt>
        <command>hello</command>
   abc
 def
    </screen>

    =>

    <screen><prompt>&gt; </prompt><command>hello</command>
   abc
 def
    </screen>

    
  Input:
    DocBook 5 document

  Output:
    DocBook 5 document

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  exclude-result-prefixes="d">

  <!-- Prevents the XSLT processor from reformatting the result ("pretty-printing") -->
  <xsl:output method="xml" indent="no"/>
  <xsl:preserve-space elements="*"/>

  <!-- HELPER TEMPLATE: Removes leading whitespace (ltrim) -->
  <xsl:template name="ltrim">
    <xsl:param name="text"/>
    <xsl:choose>
      <!-- Checks for the most common whitespace characters at the beginning -->
      <xsl:when test="starts-with($text, '&#x20;') or
        starts-with($text, '&#xA;') or
        starts-with($text, '&#xD;') or
        starts-with($text, '&#x9;')">
        <!-- Calls itself again without the first character -->
        <xsl:call-template name="ltrim">
          <xsl:with-param name="text" select="substring($text, 2)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- Outputs the text if there is no leading whitespace -->
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    RULE 1: The "Identity Transform" (fallback for everything else)
    By default, this template copies all nodes and attributes 1:1.
    This preserves the formatting of the entire document.
    -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- RULE 2: Case "prompt followed by command" -->
  <xsl:template match="d:screen[d:prompt/following-sibling::*[1][self::d:command]]">
    <xsl:copy>
      <xsl:apply-templates select="node()[not(self::text() and normalize-space() = '')]"/>
    </xsl:copy>
  </xsl:template>

  <!--
    RULE 3 (REVISED): Case "prompt followed by a text node".
    This rule matches the parent <screen> and then uses a special 'mode'
    to process its children, giving us fine-grained control.
    -->
  <xsl:template match="d:screen[d:prompt/following-sibling::node()[1][self::text()[normalize-space()!='']]]">
    <xsl:copy>
      <!-- Apply templates to children in a special mode -->
      <xsl:apply-templates select="node()" mode="compact-text-screen"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Templates for the "compact-text-screen" mode
    These only apply inside a <screen> matched by RULE 3.
    -->

  <!-- Mode Template A: For the text node immediately after a prompt, ltrim it. -->
  <xsl:template match="text()[preceding-sibling::node()[1][self::d:prompt]]" mode="compact-text-screen">
    <xsl:call-template name="ltrim">
      <xsl:with-param name="text" select="."/>
    </xsl:call-template>
  </xsl:template>

  <!-- Mode Template B: For any text node that only contains whitespace, delete it. -->
  <xsl:template match="text()[normalize-space() = '']" mode="compact-text-screen"/>

  <!-- Mode Template C: For all other nodes (like the <prompt> element), process them normally. -->
  <xsl:template match="node() | @*" mode="compact-text-screen">
    <!-- Fall back to the default processing (identity transform) -->
    <xsl:apply-templates select="."/>
  </xsl:template>

</xsl:stylesheet>

