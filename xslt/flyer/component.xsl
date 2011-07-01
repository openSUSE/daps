<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
                version='1.0'>

<xsl:attribute-set name="page.attributs">
 <xsl:attribute name="language">
  <xsl:call-template name="l10n.language"/>
 </xsl:attribute>
 <xsl:attribute name="hyphenation-character">
  <xsl:call-template name="gentext">
   <xsl:with-param name="key" select="'hyphenation-character'"/>
  </xsl:call-template>
 </xsl:attribute>
 <xsl:attribute name="hyphenation-push-character-count">
  <xsl:call-template name="gentext">
   <xsl:with-param name="key" select="'hyphenation-push-character-count'"/>
  </xsl:call-template>
 </xsl:attribute>
 <xsl:attribute name="hyphenation-remain-character-count">
  <xsl:call-template name="gentext">
   <xsl:with-param name="key" select="'hyphenation-remain-character-count'"/>
  </xsl:call-template>
 </xsl:attribute>
</xsl:attribute-set>

<xsl:template match="article">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="master-reference">
    <xsl:call-template name="select.pagemaster"/>
  </xsl:variable>
  
  <fo:page-sequence xsl:use-attribute-sets="page.attributs"
                    hyphenate="{$hyphenate}"                    
                    master-reference="{$master-reference}">
   <xsl:attribute name="format">
    <xsl:call-template name="page.number.format">
     <xsl:with-param name="master-reference" select="$master-reference"/>
    </xsl:call-template>
   </xsl:attribute>
   <xsl:attribute name="initial-page-number">
    <xsl:call-template name="initial.page.number">
     <xsl:with-param name="master-reference" select="$master-reference"/>
    </xsl:call-template>
   </xsl:attribute>
   <xsl:attribute name="force-page-count">
    <xsl:call-template name="force.page.count">
     <xsl:with-param name="master-reference" select="$master-reference"/>
    </xsl:call-template>
   </xsl:attribute>
    
    <xsl:apply-templates select="." mode="running.head.mode">
      <xsl:with-param name="master-reference" select="$master-reference"/>
    </xsl:apply-templates>

    <xsl:apply-templates select="." mode="running.foot.mode">
      <xsl:with-param name="master-reference" select="$master-reference"/>
    </xsl:apply-templates>

    <fo:flow flow-name="xsl-region-body">
      <xsl:call-template name="set.flow.properties">
        <xsl:with-param name="element" select="local-name(.)"/>
        <xsl:with-param name="master-reference" select="$master-reference"/>
      </xsl:call-template>

      <xsl:choose>
          <xsl:when test="$novell.layout = 'v1'">
            <fo:block id="{$id}" span="all">
              <xsl:call-template name="article.titlepage.recto"/>
            </fo:block>
            <xsl:choose>
              <xsl:when test="$fop1.extensions != 0">
                <fo:block span="all" font-family="{$sans.font.family}"
                  padding-top="-8em" margin-bottom="8em">
                  <fo:block background-color="{$flyer.color}"
                    padding-left="5em" padding-right="5em"
                    padding-top="14em" padding-bottom="3em"
                    height="8.4cm">
                    <xsl:call-template name="article.titlepage.recto"/>
                  </fo:block>
                  <fo:block text-align="right" padding-bottom=".5em"
                    padding-top=".5em">
                    <fo:inline padding-left="1em"
                      border-left="0.2pt dotted black">
                      <xsl:comment>NOVELL&#x00AE; QUICK START CARD </xsl:comment>
                      <xsl:call-template name="gentext">
                        <xsl:with-param name="key"
                          select="'FlyerQuickstart'"/>
                      </xsl:call-template>
                    </fo:inline>
                  </fo:block>
                </fo:block>
              </xsl:when>
              <xsl:otherwise>
                <fo:block-container left="-5pt" top="-5pt" right="-5pt"
                  absolute-position="fixed" span="all" id="{$id}"
                  height="8.4cm" background-color="{$flyer.color}">
                  <fo:block-container margin-left="{$page.margin.inner}"
                    space-before="5.19cm"
                    space-before.conditionality="retain">
                    <fo:block>
                      <xsl:call-template name="article.titlepage.recto"
                      />
                    </fo:block>
                  </fo:block-container>
                </fo:block-container>
                <fo:block-container left="{$page.margin.inner}"
                  top="8.4cm" right="{$page.margin.outer}"
                  absolute-position="fixed" space-before="0em"
                  space-after="1.2cm" span="all">
                  <fo:block text-align="right"
                    font-family="{$sans.font.family}">
                    <fo:inline padding-left="1em" padding-top="0.25em"
                      border-left="0.2pt dotted black">
                      <xsl:comment>NOVELL&#x00AE; QUICK START CARD </xsl:comment>
                      <xsl:call-template name="gentext">
                        <xsl:with-param name="key"
                          select="'FlyerQuickstart'"/>
                      </xsl:call-template>
                    </fo:inline>
                  </fo:block>
                </fo:block-container>

                <fo:block span="all" space-before="9cm"
                  space-before.conditionality="retain">
                  <fo:leader leader-pattern="space"/>
                </fo:block>
              </xsl:otherwise>
            </xsl:choose>
            <fo:block span="all" xsl:use-attribute-sets="abstract.titlepage.recto.style">
        <xsl:if test="$fop1.extensions != 0">
          <xsl:attribute name="margin-bottom">2em</xsl:attribute>
        </xsl:if>
        <!--<xsl:apply-templates select="subtitle"
                             mode="article.titlepage.recto.auto.mode"/>-->
        <xsl:apply-templates select="abstract"
                             mode="article.titlepage.recto.auto.mode"/>
      </fo:block>
          </xsl:when>
        <xsl:otherwise>
          <fo:block span="all" margin-top="9pt">
            <fo:table color="white" space-after="1em">
                <fo:table-column
                  column-width="proportional-column-width(1.97)"/><!-- 124mm -->
                <fo:table-column column-width="4mm"/>
                <fo:table-column
                  column-width="proportional-column-width(1.00)"/><!-- 63mm -->
                <fo:table-body>
                  <fo:table-cell background-color="{$flyer.color}" >
                    <fo:block-container height="41mm" left="-10pt">
                      <fo:block margin="1.75em" hyphenate="false"
                        space-after="-25pt">
                        <xsl:apply-templates select="title" 
                          mode="article.titlepage.recto.auto.mode"/>
                      </fo:block>
                      <fo:block margin="1.5em" hyphenate="false"
                        font-size="12pt">
                          <xsl:apply-templates
                            select="articleinfo/date"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell background-color="#E4E5E6"
                    color="#FF1A00">
                    <fo:block-container height="41mm" right="10pt">
                      <fo:block font-size="14pt"
                        margin-top="32.5mm" 
                        text-align="right" 
                        margin-right=".5em"
                        >Novell<fo:inline font-size="7.5pt">®</fo:inline>
                        </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                </fo:table-body>
              </fo:table>
           <!--</fo:block>-->
<!--          
          <fo:block-container left="5mm"  top="9mm" right="5mm"
            absolute-position="fixed" span="all"
             height="41mm + 1em"
            id="{$id}">
              <fo:table color="white">
                <fo:table-column
                  column-width="proportional-column-width(1.97)"/><!-\- 124mm -\->
                <fo:table-column column-width="4mm"/>
                <fo:table-column
                  column-width="proportional-column-width(1.00)"/><!-\- 63mm -\->
                <fo:table-body>
                  <fo:table-cell background-color="{$flyer.color}">
                    <fo:block-container height="41mm">
                      <fo:block margin="1.75em" hyphenate="false">
                        <xsl:apply-templates select="title" 
                          mode="article.titlepage.recto.auto.mode"/>
                      </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                  <fo:table-cell>
                    <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell background-color="#E4E5E6"
                    color="#FF1A00">
                    <fo:block-container height="41mm">
                      <fo:block font-size="14pt"
                        margin-top="32.5mm" 
                        text-align="right" 
                        margin-right=".5em"
                        >Novell<fo:inline font-size="7.5pt">®</fo:inline>
                        </fo:block>
                    </fo:block-container>
                  </fo:table-cell>
                </fo:table-body>
              </fo:table>
          </fo:block-container>
          <fo:block space-after="41mm + 2em">&#xa0;</fo:block>
-->
          <!--<fo:block span="all" >-->
<!-- fs 2011-03-28:
     The following code throws an error when building with fop:
     "xsl:attribute: Cannot add attributes to an element if children
      have been already added to the element."

        <xsl:if test="$fop1.extensions != 0">
          <xsl:attribute name="margin-bottom">2em</xsl:attribute>
        </xsl:if>
-->
        <xsl:apply-templates select="subtitle"
                             mode="article.titlepage.recto.auto.mode"/>
        <xsl:apply-templates select="abstract"
                             mode="article.titlepage.recto.auto.mode"/>
      </fo:block>
        </xsl:otherwise>
      </xsl:choose>
      
      
      <xsl:variable name="toc.params">
        <xsl:call-template name="find.path.params">
          <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="contains($toc.params, 'toc')">
        <xsl:call-template name="component.toc"/>
        <xsl:call-template name="component.toc.separator"/>
      </xsl:if>

      <!-- Everything without a legal, process it: -->
      <xsl:apply-templates select="*[not(@role='legal')]"/>
      
      <!-- Column adjustment -->
      <xsl:if test="$fop1.extensions = 0">
        <fo:block span="all"><fo:leader/></fo:block>
      </xsl:if>
    </fo:flow>
  </fo:page-sequence>
  
  <!-- This page-sequence is just for the column adjustment before and after. -->
  <xsl:choose>
    <xsl:when test="$fop1.extensions = 0">
      <fo:page-sequence xsl:use-attribute-sets="page.attributs"
       hyphenate="{$hyphenate}"
        master-reference="{$master-reference}">
     <xsl:attribute name="format">
      <xsl:call-template name="page.number.format">
       <xsl:with-param name="master-reference"
        select="$master-reference"/>
      </xsl:call-template>
     </xsl:attribute>
     <xsl:attribute name="initial-page-number">
      <xsl:call-template name="initial.page.number">
       <xsl:with-param name="master-reference"
        select="$master-reference"/>
      </xsl:call-template>
     </xsl:attribute>
     <xsl:attribute name="force-page-count">
      <xsl:call-template name="force.page.count">
       <xsl:with-param name="master-reference"
        select="$master-reference"/>
      </xsl:call-template>
     </xsl:attribute>

        
        <xsl:apply-templates select="." mode="running.head.mode">
          <xsl:with-param name="master-reference" select="$master-reference"/>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="." mode="running.foot.mode">
          <xsl:with-param name="master-reference" select="$master-reference"/>
        </xsl:apply-templates>
        
        <fo:flow flow-name="xsl-region-body">
          <xsl:call-template name="set.flow.properties">
            <xsl:with-param name="element" select="local-name(.)"/>
            <xsl:with-param name="master-reference" select="$master-reference"/>
          </xsl:call-template>
          <xsl:apply-templates select="*[@role='legal']"/>
          <xsl:if test="false()">
            <fo:block span="all">
              <fo:footnote>
                <fo:inline/>
                <fo:footnote-body text-align="right" margin-left="0pt"
                  margin-right="0pt">
                  <fo:block padding="0pt">
                    <fo:external-graphic width="3.5cm"
                      content-width="scale-to-fit"
                      content-height="scale-to-fit"
                      src="url(&quot;{$dtdroot}/xslt/images/svg/novell-logo.svg&quot;)"/>
                    <!--<fo:external-graphic width="3.5cm"
                      content-width="scale-to-fit"
                      content-height="scale-to-fit"
                      src="url(&quot;{$dtdroot}/xslt/images/svg/suse-logo.svg&quot;)"
                    />-->
                  </fo:block>
                  <fo:block
                    xsl:use-attribute-sets="copyright.flyer.properties">
                    <fo:block space-before="0.75em">
                      <xsl:call-template name="gentext">
                        <xsl:with-param name="key"
                          select="'FlyerMadeby'"/>
                      </xsl:call-template>
                    </fo:block>
                  </fo:block>
                </fo:footnote-body>
              </fo:footnote>
            </fo:block>
            </xsl:if>
        </fo:flow>
      </fo:page-sequence>
    </xsl:when>
    <xsl:otherwise>
     <fo:page-sequence xsl:use-attribute-sets="page.attributs"
        hyphenate="{$hyphenate}"
        master-reference="{$master-reference}">
     <xsl:attribute name="format">
      <xsl:call-template name="page.number.format">
       <xsl:with-param name="master-reference"
        select="$master-reference"/>
      </xsl:call-template>
     </xsl:attribute>
     <xsl:attribute name="initial-page-number">
      <xsl:call-template name="initial.page.number">
       <xsl:with-param name="master-reference"
        select="$master-reference"/>
      </xsl:call-template>
     </xsl:attribute>
     <xsl:attribute name="force-page-count">
      <xsl:call-template name="force.page.count">
       <xsl:with-param name="master-reference"
        select="$master-reference"/>
      </xsl:call-template>
     </xsl:attribute>
       
        <xsl:apply-templates select="." mode="running.head.mode">
          <xsl:with-param name="master-reference" select="$master-reference"/>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="." mode="running.foot.mode">
          <xsl:with-param name="master-reference" select="$master-reference"/>
        </xsl:apply-templates>
        
        <fo:flow flow-name="xsl-region-body">
          <xsl:call-template name="set.flow.properties">
            <xsl:with-param name="element" select="local-name(.)"/>
            <xsl:with-param name="master-reference" select="$master-reference"/>
          </xsl:call-template>
          <xsl:apply-templates select="*[@role='legal']"/>
            <fo:block span="all" text-align="right"
                margin-top="2em"
                margin-left="0pt"
                margin-right="0pt">
                  <fo:block padding="0pt">
                    <!-- Original size: width=190pt, height=45pt -->
                    <!-- For some reason -->
                    <!--<fo:external-graphic width="2.5cm"
                      height="0.59"
                      content-width="scale-to-fit"
                      content-height="scale-to-fit"
                      src="url(&quot;{$dtdroot}/xslt/images/svg/novell-logo.svg&quot;)"/>
                   <fo:leader leader-length="2em" leader-pattern="space"/>-->
                    <fo:external-graphic width="2.5cm"
                      content-width="scale-to-fit"
                      content-height="scale-to-fit"
                      src="url(&quot;{$dtdroot}/xslt/images/svg/suse-logo.svg&quot;)"
                    />
                  </fo:block>
                  <fo:block
                    xsl:use-attribute-sets="copyright.flyer.properties">
                    <fo:block space-before="0.75em">
                      <xsl:call-template name="gentext">
                        <xsl:with-param name="key"
                          select="'FlyerMadeby'"/>
                      </xsl:call-template>
                    </fo:block>
                  </fo:block>
            </fo:block>
        </fo:flow>
      </fo:page-sequence>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="article/articleinfo"></xsl:template>
<xsl:template match="article/title"></xsl:template>
<xsl:template match="article/titleabbrev"></xsl:template>
<xsl:template match="article/subtitle"></xsl:template>
<xsl:template match="article/abstract"></xsl:template>


<xsl:template match="title" mode="article.titlepage.recto.auto.mode">
   <fo:block xsl:use-attribute-sets="article.titlepage.recto.style"
          font-size="22pt">
       <xsl:apply-templates mode="article.titlepage.recto.auto.mode"/>
      <!--<xsl:call-template name="component.title">
         <xsl:with-param name="node" select="ancestor-or-self::chapter[1]"/>
      </xsl:call-template>-->
   </fo:block>
</xsl:template>

<xsl:template match="subtitle" mode="article.titlepage.recto.auto.mode">
   <fo:block background-color="{$flyer.color}" color="white"
     xsl:use-attribute-sets="article.subtitlepage.recto.style">
     <xsl:choose>
       <xsl:when test="$novell.layout != 'v2'">
         <xsl:attribute name="font-size">16pt</xsl:attribute>
         <xsl:apply-templates mode="article.titlepage.recto.auto.mode"/>
         <!--<xsl:value-of select="concat(productname, ' ', 
                                      productnumber, text()
                                     )"/>-->
       </xsl:when>
       <xsl:otherwise>
         <xsl:value-of select="."/>
       </xsl:otherwise>
     </xsl:choose>
   </fo:block>
</xsl:template>

<xsl:template match="subtitle/productname" mode="article.titlepage.recto.auto.mode">
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="subtitle[productname]/text()" mode="article.titlepage.recto.auto.mode">
</xsl:template>
 
  <!-- if an element isn't found in this mode, -->
  <!-- try the generic titlepage.mode -->
<xsl:template match="article/abstract|article/articleinfo/abstract" mode="article.titlepage.recto.auto.mode">
  <xsl:apply-templates select="." mode="abstract"/>
</xsl:template>


<xsl:template match="emphasis" mode="article.titlepage.recto.auto.mode">
   <xsl:apply-templates mode="article.titlepage.recto.auto.mode"/>
</xsl:template>

<xsl:template match="productname" mode="article.titlepage.recto.auto.mode">
   <fo:block space-after="0.25em">
     <xsl:apply-templates mode="article.titlepage.recto.auto.mode"/>
   </fo:block>
</xsl:template>

<xsl:template match="processing-instruction('suse')" 
  mode="article.titlepage.recto.auto.mode">
  <xsl:call-template name="suse-pi"/>
</xsl:template>


<xsl:template match="abstract" mode="abstract">
   <fo:block><xsl:apply-templates mode="abstract"/></fo:block>
  <xsl:if test="$novell.layout != 'v1'">
    <fo:block space-before="1em" text-align-last="justify" >
      <fo:leader color="#E4E5E6"  background-color="#E4E5E6"  
         leader-pattern-width="1em" line-height="1.4em"
        leader-pattern="rule" height="1em"
        keep-with-next.within-line="always"/><!---->
    </fo:block>
  </xsl:if>
</xsl:template>

<xsl:template match="para" mode="abstract">
   <fo:block xsl:use-attribute-sets="normal.para.spacing">
     <xsl:apply-templates />
   </fo:block>
</xsl:template>

<xsl:template match="*" mode="abstract">
   <xsl:apply-templates/>
</xsl:template>



<xsl:template match="abstract/title" mode="titlepage.abstract.title.mode"/>
<xsl:template match="abstract/title" mode="titlepage.mode"/>
<xsl:template match="chapter/abstract"/>


<xsl:template match="note|important|warning|caution|tip" mode="object.title.template">
  
  <xsl:text>[</xsl:text>
  <xsl:call-template name="gentext">
        <xsl:with-param name="key">
          <xsl:choose>
            <xsl:when test="local-name(.) = 'caution'">Caution</xsl:when>
            <xsl:when test="local-name(.) = 'note'">Note</xsl:when>
            <xsl:when test="local-name(.) = 'important'">Important</xsl:when>
            <xsl:when test="local-name(.) = 'tip'">Tip</xsl:when>
            <xsl:when test="local-name(.) = 'warning'">Warning</xsl:when>
            <xsl:otherwise>
              <xsl:message>Unknown element <xsl:value-of
                select="name()"/>.</xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
  </xsl:call-template>
  <xsl:text>] </xsl:text>
  
  <xsl:apply-templates select="." mode="title.markup"/>
</xsl:template>

</xsl:stylesheet>

