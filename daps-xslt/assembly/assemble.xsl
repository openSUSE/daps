<?xml version="1.0" encoding="utf-8"?>
<!--
  This file is a customization layer for the original assemble.xsl stylesheet
  from the upstream DocBook stylesheets.

-->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="exsl d xlink d"
  version="1.0">

<xsl:import href="http://docbook.sourceforge.net/release/xsl-ns/current/assembly/assemble.xsl"/>

<xsl:param name="docbook.version">5.2</xsl:param>
<xsl:param name="preserve-xmlbase" select="0"/><!-- Preserve xml:base (=1), discard it (=0) -->


<xsl:preserve-space elements="*"/>
<xsl:strip-space elements="d:assembly d:structure d:module d:resources d:resource"/>



<xsl:template match="d:module[@resourceref] | d:structure[@resourceref]">
  <xsl:param name="parent" select="''"/>

  <xsl:variable name="module" select="."/>
  <xsl:variable name="resourceref" select="@resourceref"/>
  <xsl:variable name="resource" select="key('id', $resourceref)"/>

  <!-- Determine whether a filterin or filterout element controls
       whether this module or structure should occur in the output
       document. -->
  <xsl:variable name="effectivity.exclude">
    <xsl:apply-templates select="child::d:filterin | child::d:filterout"
      mode="evaluate.effectivity" />
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="not($resource)">
      <xsl:message terminate="yes">
        <xsl:text>ERROR: no xml:id matches @resourceref = '</xsl:text>
        <xsl:value-of select="$resourceref"/>
        <xsl:text>'.</xsl:text>
      </xsl:message>
    </xsl:when>
    <xsl:when test="not($resource/self::d:resource)">
      <xsl:message terminate="yes">
        <xsl:text>ERROR: xml:id matching @resourceref = '</xsl:text>
        <xsl:value-of select="$resourceref"/>
        <xsl:text> is not a resource element'.</xsl:text>
      </xsl:message>
    </xsl:when>
  </xsl:choose>

  <xsl:variable name="href.att" select="$resource/@href"/>

  <xsl:variable name="fragment.id">
    <xsl:if test="contains($href.att, '#')">
      <xsl:value-of select="substring-after($href.att, '#')"/>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="filename">
    <xsl:choose>
      <xsl:when test="string-length($fragment.id) != 0">
        <xsl:value-of select="substring-before($href.att, '#')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$href.att"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="fileref">
    <xsl:choose>
      <xsl:when test="$resource/ancestor::d:resources/@xml:base and $preserve-xmlbase != 0">
        <xsl:value-of
            select="concat($resource/ancestor::d:resources[@xml:base][1]/@xml:base,
                                 '/', $filename)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$filename"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="string-length($fileref) = 0">
      <!-- A resource without an @href value is an error -->
      <xsl:message terminate="yes">
        <xsl:text>ERROR: resource with @xml:id='</xsl:text>
        <xsl:value-of select="$resourceref"/>
        <xsl:text>' does not resolve to a filename.</xsl:text>
      </xsl:message>
    </xsl:when>

    <xsl:otherwise>
      <xsl:variable name="ref.file.content" select="document($fileref,/)"/>

      <!-- selects root or fragment depending on if $fragment is blank -->
      <xsl:variable name="ref.content.element"
        select="$ref.file.content/*[1][$fragment.id = ''] |
                $ref.file.content/*[1][$fragment.id != '']/
                   descendant-or-self::*[@xml:id = $fragment.id]"/>

      <xsl:variable name="ref.content.nodes">
        <xsl:apply-templates select="$ref.content.element" mode="ref.content.nodes"/>
      </xsl:variable>

      <xsl:variable name="ref.content" select="exsl:node-set($ref.content.nodes)/*[1]"/>

      <xsl:if test="count($ref.content) = 0">
        <xsl:message terminate="yes">
          <xsl:text>ERROR: @href = '</xsl:text>
          <xsl:value-of select="$fileref"/>
          <xsl:text>' has no content or is unresolved.</xsl:text>
        </xsl:message>
      </xsl:if>

      <xsl:variable name="ref.name" select="local-name($ref.content)"/>

      <xsl:variable name="element.name">
        <xsl:apply-templates select="." mode="compute.element.name">
          <xsl:with-param name="ref.name" select="$ref.name"/>
        </xsl:apply-templates>
      </xsl:variable>

      <xsl:variable name="omittitles.property">
        <xsl:call-template name="compute.output.value">
          <xsl:with-param name="property">omittitles</xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
    
      <xsl:variable name="contentonly.property">
        <xsl:call-template name="compute.output.value">
          <xsl:with-param name="property">contentonly</xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
    
      <!-- get any merge resource element before changing context -->
      <xsl:variable name="merge.resourceref" select="$module/d:merge[1]/@resourceref"/>
      <xsl:variable name="merge.resource" select="key('id', $merge.resourceref)"/>

      <xsl:choose>
        <xsl:when test="contains($effectivity.exclude, 'exclude')">
          <!-- Do not render a module if it includes a filterout 
          element that includes an effectivity attribute that matches 
          an effectivity parameter passed to the assembly stylesheet. 
          Do not render a module if it includes a filterin element that 
          does not match an effectivity parameter passed to the 
          assembly stylesheet. -->
        </xsl:when>
        <xsl:when test="$contentonly.property = 'true' or 
                        $contentonly.property = 'yes' or
                        $contentonly.property = '1'">
          <xsl:apply-templates select="$ref.content/node()" mode="copycontent">
            <xsl:with-param name="omittitles" select="$omittitles.property"/>
          </xsl:apply-templates>
        </xsl:when>
        <!-- use xsl:copy if using the ref element itself to get its namespaces -->
        <xsl:when test="$element.name = local-name($ref.content)">
          <!-- must use for-each to set context node for xsl:copy -->
          <xsl:for-each select="$ref.content">
            <xsl:copy>
              <xsl:if test="$preserve-xmlbase != 0">
                <xsl:attribute name="xml:base">
                  <xsl:value-of select="$fileref"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:copy-of select="@*[not(name() = 'xml:id')]"/>
              <xsl:choose>
                <!-- Use the module's xml:id if it has one -->
                <xsl:when test="$module/@xml:id">
                  <xsl:attribute name="xml:id">
                    <xsl:value-of select="$module/@xml:id"/>
                  </xsl:attribute>
                </xsl:when>
                <!-- otherwise use the resource's id -->
                <xsl:otherwise>
                  <xsl:copy-of select="@xml:id"/>
                </xsl:otherwise>
              </xsl:choose>

              <xsl:call-template name="merge.info">
                <xsl:with-param name="merge.element" select="$module/d:merge"/>
                <xsl:with-param name="ref.content" select="$ref.content"/>
                <xsl:with-param name="omittitles" select="$omittitles.property"/>
                <xsl:with-param name="resource" select="$merge.resource"/>
              </xsl:call-template>

              <!-- copy through all but titles, which moved to info -->
              <xsl:apply-templates select="node()
                       [not(local-name() = 'title') and
                        not(local-name() = 'subtitle') and
                        not(local-name() = 'info') and
                        not(local-name() = 'titleabbrev')]" mode="copycontent"/>

              <xsl:apply-templates select="$module/node()"> 
                <xsl:with-param name="parent" select="$element.name"/>
              </xsl:apply-templates>
            </xsl:copy>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <!-- create the element instead of copying it -->
          <xsl:element name="{$element.name}" namespace="http://docbook.org/ns/docbook">
            <xsl:if test="$preserve-xmlbase != 0">
              <xsl:attribute name="xml:base">
                <xsl:value-of select="$fileref"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="$ref.content/@*[not(name() = 'xml:id')]"/>
            <xsl:choose>
              <!-- Use the module's xml:id if it has one -->
              <xsl:when test="@xml:id">
                <xsl:attribute name="xml:id">
                  <xsl:value-of select="@xml:id"/>
                </xsl:attribute>
              </xsl:when>
              <!-- otherwise use the resource's id -->
              <xsl:when test="$ref.content/@xml:id">
                <xsl:attribute name="xml:id">
                  <xsl:value-of select="$ref.content/@xml:id"/>
                </xsl:attribute>
              </xsl:when>
            </xsl:choose>

            <xsl:call-template name="merge.info">
              <xsl:with-param name="merge.element" select="d:merge"/>
              <xsl:with-param name="ref.content" select="$ref.content"/>
              <xsl:with-param name="omittitles" select="$omittitles.property"/>
              <xsl:with-param name="resource" select="$merge.resource"/>
            </xsl:call-template>

            <!-- copy through all but titles, which moved to info -->
            <xsl:apply-templates select="$ref.content/node()
                     [not(local-name() = 'title') and
                      not(local-name() = 'subtitle') and
                      not(local-name() = 'info') and
                      not(local-name() = 'titleabbrev')]" mode="copycontent"/>

            <xsl:apply-templates> 
              <xsl:with-param name="parent" select="$element.name"/>
            </xsl:apply-templates>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>



  <xsl:template name="merge.info">
  <xsl:param name="merge.element" select="NOTANODE"/>
  <xsl:param name="ref.content" select="NOTANODE"/>
  <xsl:param name="omittitles"/> 
  <xsl:param name="resource"/> 

  <!-- a merge element may use resourceref as well as literal content -->
  <!-- any literal content overrides the merge resourceref content -->
  <xsl:variable name="merge.ref.content">
    <xsl:if test="$merge.element/@resourceref">

      <xsl:choose>
        <xsl:when test="not($resource)">
          <xsl:message terminate="yes">
            <xsl:text>ERROR: no xml:id matches @resourceref = '</xsl:text>
            <xsl:value-of select="$merge.element/@resourceref"/>
            <xsl:text>'.</xsl:text>
          </xsl:message>
        </xsl:when>
        <xsl:when test="not($resource/self::d:resource)">
          <xsl:message terminate="yes">
            <xsl:text>ERROR: xml:id matching @resourceref = '</xsl:text>
            <xsl:value-of select="$merge.element/@resourceref"/>
            <xsl:text> is not a resource element'.</xsl:text>
          </xsl:message>
        </xsl:when>
      </xsl:choose>

      <xsl:variable name="href.att" select="$resource/@href"/>

      <xsl:variable name="fileref">
        <xsl:choose>
          <xsl:when test="$resource/ancestor::d:resources/@xml:base and $preserve-xmlbase != 0">
            <xsl:value-of 
                select="concat($resource/ancestor::d:resources[@xml:base][1]/@xml:base,
                               '/', $href.att)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$href.att"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="string-length($fileref) != 0">
        <xsl:copy-of select="document($fileref,/)"/>
      </xsl:if>
    </xsl:if>
  </xsl:variable>

  <!-- Copy all metadata from merge.ref.content to a single node-set -->
  <xsl:variable name="merge.ref.nodes">
    <xsl:copy-of select="exsl:node-set($merge.ref.content)/*/d:title[1]"/>
    <xsl:copy-of select="exsl:node-set($merge.ref.content)/*/d:titleabbrev[1]"/>
    <xsl:copy-of select="exsl:node-set($merge.ref.content)/*/d:subtitle[1]"/>
    <xsl:copy-of select="exsl:node-set($merge.ref.content)/*/d:info[1]/node()"/>
  </xsl:variable>
  <xsl:variable name="merge.ref.nodeset" select="exsl:node-set($merge.ref.nodes)"/>
  <!-- copy attributes separately so they can be applied in the right place -->
  <xsl:variable name="merge.ref.attributes" select="exsl:node-set($merge.ref.content)/*/d:info[1]/@*"/>

  <xsl:variable name="omittitles.boolean">
    <xsl:choose>
      <xsl:when test="$omittitles = 'yes' or $omittitles = 'true' or $omittitles = '1'">
        <xsl:value-of select="1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <!-- output info if there is any -->
  <xsl:if test="$merge.element/node() or 
                $merge.ref.nodeset or
                $merge.ref.attributes or 
                $ref.content/d:info/node() or
                $ref.content/d:title[$omittitles.boolean = 0] or
                $ref.content/d:subtitle[$omittitles.boolean = 0] or
                $ref.content/d:titleabbrev[$omittitles.boolean = 0]">

    <xsl:variable name="ref.info" select="$ref.content/d:info"/>
    <xsl:variable name="ref.title" select="$ref.content/d:title"/>
    <xsl:variable name="ref.subtitle" select="$ref.content/d:subtitle"/>
    <xsl:variable name="ref.titleabbrev" select="$ref.content/d:titleabbrev"/>
    <xsl:variable name="ref.info.title" select="$ref.content/d:info/d:title"/>
    <xsl:variable name="ref.info.subtitle" select="$ref.content/d:info/d:subtitle"/>
    <xsl:variable name="ref.info.titleabbrev" select="$ref.content/d:info/d:titleabbrev"/>

    <info>
      <!-- First copy through any merge attributes and elements and comments -->
      <xsl:copy-of select="$merge.element/@*[not(local-name(.) = 'resourceref')]"/>
      
      <!-- add any attributes from the merge resource -->
      <xsl:copy-of select="$merge.ref.attributes"/>

      <!-- And copy any resource info attributes not in merge-->
      <xsl:for-each select="$ref.info/@*">
        <xsl:variable name="resource.att" select="local-name(.)"/>
        <xsl:choose>
          <xsl:when test="$merge.element/@*[local-name(.) = $resource.att]">
            <!-- do nothing because overridden -->
          </xsl:when>
          <xsl:when test="$merge.ref.attributes[local-name(.) = $resource.att]">
            <!-- do nothing because overridden -->
          </xsl:when>
          <xsl:otherwise>
            <!-- copy through if not overridden -->
            <xsl:copy-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>

      <!-- Copy through the merge children as they have highest priority -->
      <xsl:copy-of select="$merge.element/node()"/>

      <!-- and copy through those merge resource elements not in merge element -->
      <xsl:for-each select="$merge.ref.nodeset/node()">
        <xsl:variable name="resource.node" select="local-name(.)"/>
        <xsl:choose>
          <xsl:when test="self::processing-instruction()">
            <xsl:copy-of select="."/>
          </xsl:when>
          <xsl:when test="self::comment()">
            <xsl:copy-of select="."/>
          </xsl:when>
          <xsl:when test="$merge.element/node()[local-name(.) = $resource.node]">
            <!-- do nothing because overridden -->
          </xsl:when>
          <xsl:otherwise>
            <!-- copy through -->
            <xsl:copy-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>

      <!-- And copy any module's resource info node not in merge or merge.ref -->
      <xsl:for-each select="$ref.info/node() | 
                            $ref.title[$omittitles.boolean = 0] |
                            $ref.subtitle[$omittitles.boolean = 0] |
                            $ref.titleabbrev[$omittitles.boolean = 0] |
                            $ref.info.title[$omittitles.boolean = 0] |
                            $ref.info.subtitle[$omittitles.boolean = 0] |
                            $ref.info.titleabbrev[$omittitles.boolean = 0]">
        <xsl:variable name="resource.node" select="local-name(.)"/>
        <xsl:choose>
          <xsl:when test="$merge.element/node()[local-name(.) = $resource.node]">
            <!-- do nothing because overridden -->
          </xsl:when>
          <xsl:when test="$merge.ref.nodeset/*[local-name(.) = $resource.node]">
            <!-- do nothing because overridden -->
          </xsl:when>
          <xsl:otherwise>
            <!-- copy through -->
            <xsl:copy-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </info>
  </xsl:if>
</xsl:template>


</xsl:stylesheet>
