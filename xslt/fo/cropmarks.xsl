<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format"
 version="1.0">

 <xsl:param name="tab.border">1pt solid black</xsl:param>
 <xsl:param name="tab.width">1cm</xsl:param>

<xsl:template name="select.user.pagemaster">
 <xsl:param name="element"/>
 <xsl:param name="pageclass"/>
 <xsl:param name="default-pagemaster"/>
 <xsl:choose>
 <xsl:when test="$element = 'appendix'">tabbed-back</xsl:when>
 <xsl:otherwise>tabbed-body</xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template name="user.pagemasters">
 <fo:simple-page-master master-name="tabbed-back-odd-first"
 page-width="{$page.width}"
 page-height="{$page.height}"
 margin-top="{$page.margin.top} -
 {$cropmarks.bleeding}"
 margin-bottom="{$page.margin.bottom} -
 {$cropmarks.bleeding}"
 margin-left="{$page.margin.outer} -
 {$cropmarks.bleeding}"
 margin-right="{$page.margin.inner} -
 {$cropmarks.bleeding}">
 <fo:region-body region-name="xsl-region-body"
 margin-left="{$body.margin.inner} + {$cropmarks.bleeding}"
 margin-right="{$body.margin.outer} +
 {$cropmarks.bleeding}"
 margin-bottom="{$body.margin.bottom} +
 {$cropmarks.bleeding}"
 margin-top="{$body.margin.top} + {$cropmarks.bleeding}"
 column-gap="{$column.gap.back}"
 column-count="{$column.count.back}"/>

 <fo:region-before region-name="xsl-region-before-odd-first"
 extent="{$region.before.extent} + {$cropmarks.bleeding}"
 display-align="after"/>
 <fo:region-after region-name="xsl-region-after-odd-first"
 extent="{$region.after.extent} + {$cropmarks.bleeding}"
 display-align="before"
 />
 <fo:region-start region-name="xsl-region-start-odd-first"
 extent="{$tab.width} + {$cropmarks.bleeding}"
 display-align="after"/>
 <fo:region-end region-name="xsl-region-end-odd-first"
 extent="{$tab.width} + {$cropmarks.bleeding}"
 display-align="after"/>
 </fo:simple-page-master>

 <fo:simple-page-master master-name="tabbed-back-odd"
 page-width="{$page.width}"
 page-height="{$page.height}"
 margin-top="{$page.margin.top} - {$cropmarks.bleeding}"
 margin-bottom="{$page.margin.bottom} -
 {$cropmarks.bleeding}"
 margin-left="{$page.margin.outer} -
 {$cropmarks.bleeding}"
 margin-right="{$page.margin.inner} -
 {$cropmarks.bleeding}">
 <fo:region-body region-name="xsl-region-body"
 margin-left="{$body.margin.inner} + {$cropmarks.bleeding}"
 margin-right="{$body.margin.outer} +
 {$cropmarks.bleeding}"
 margin-bottom="{$body.margin.bottom} +
 {$cropmarks.bleeding}"
 margin-top="{$body.margin.top} + {$cropmarks.bleeding}"
 column-gap="{$column.gap.back}"
 column-count="{$column.count.back}"/>

 <fo:region-before region-name="xsl-region-before-odd"
 extent="{$region.before.extent} + {$cropmarks.bleeding}"
 display-align="after"/>
 <fo:region-after region-name="xsl-region-after-odd"
 extent="{$region.after.extent} + {$cropmarks.bleeding}"
 display-align="before"
 />
 <fo:region-start region-name="xsl-region-start-odd"
 extent="{$tab.width} + {$cropmarks.bleeding}"
 display-align="after"/>
 <fo:region-end region-name="xsl-region-end-odd"
 extent="{$tab.width} + {$cropmarks.bleeding}"
 display-align="after"/>
 </fo:simple-page-master>

 <fo:simple-page-master master-name="tabbed-back-even"
 page-width="{$page.width}"
 page-height="{$page.height}"
 margin-top="{$page.margin.top} - {$cropmarks.bleeding}"
 margin-bottom="{$page.margin.bottom} -
 {$cropmarks.bleeding}"
 margin-left="{$page.margin.outer} -
 {$cropmarks.bleeding}"
 margin-right="{$page.margin.inner} -
 {$cropmarks.bleeding}">
 <fo:region-body region-name="xsl-region-body"
 margin-left="{$body.margin.inner} + {$cropmarks.bleeding}"
 margin-right="{$body.margin.outer} +
 {$cropmarks.bleeding}"
 margin-bottom="{$body.margin.bottom} +
 {$cropmarks.bleeding}"
 margin-top="{$body.margin.top} + {$cropmarks.bleeding}"
 column-gap="{$column.gap.back}"
 column-count="{$column.count.back}"/>

 <fo:region-before region-name="xsl-region-before-even"
 extent="{$region.before.extent} + {$cropmarks.bleeding}"
 display-align="after"/>
 <fo:region-after region-name="xsl-region-after-even"
 extent="{$region.after.extent} + {$cropmarks.bleeding}"
 display-align="before" />
 <fo:region-start region-name="xsl-region-start-even"
 extent="{$tab.width} + {$cropmarks.bleeding}"
 display-align="after"/>
 <fo:region-end region-name="xsl-region-end-even"
 extent="{$tab.width} + {$cropmarks.bleeding}"
 display-align="after"/>
 </fo:simple-page-master>


 <fo:simple-page-master master-name="tabbed-back-even-last"
 page-width="{$page.width}"
 page-height="{$page.height}"
 margin-top="{$page.margin.top} - {$cropmarks.bleeding}"
 margin-bottom="{$page.margin.bottom} -
 {$cropmarks.bleeding}"
 margin-left="{$page.margin.outer} -
 {$cropmarks.bleeding}"
 margin-right="{$page.margin.inner}">
 <fo:region-body region-name="xsl-region-body"
 margin-left="{$body.margin.inner} + {$cropmarks.bleeding}"
 margin-right="{$body.margin.outer}"
 margin-bottom="{$body.margin.bottom} +
 {$cropmarks.bleeding}"
 margin-top="{$body.margin.top} + {$cropmarks.bleeding}"
 column-gap="{$column.gap.back}"
 column-count="{$column.count.back}"/>

 <fo:region-before region-name="xsl-region-before-even-last"
 extent="{$region.before.extent} + {$cropmarks.bleeding}"
 display-align="after"/>
 <fo:region-after region-name="xsl-region-after-even-last"
 extent="{$region.after.extent} + {$cropmarks.bleeding}"
 display-align="before" />
 <fo:region-start region-name="xsl-region-start-even-last"
 extent="{$tab.width} + {$cropmarks.bleeding}"
 display-align="after"/>
 <fo:region-end region-name="xsl-region-end-even-last"
 extent="{$tab.width}"
 />

 </fo:simple-page-master>

 <fo:simple-page-master master-name="tabbed-body-odd-first"
 page-width="{$page.width}"
 page-height="{$page.height}"
 margin-top="{$page.margin.top} -
 {$cropmarks.bleeding}"
 margin-bottom="{$page.margin.bottom} -
 {$cropmarks.bleeding}"
 margin-left="{$page.margin.outer} -
 {$cropmarks.bleeding}"
 margin-right="{$page.margin.inner} -
 {$cropmarks.bleeding}">
 <fo:region-body region-name="xsl-region-body"
 margin-left="{$body.margin.inner} + {$cropmarks.bleeding}"
 margin-right="{$body.margin.outer} +
 {$cropmarks.bleeding}"
 margin-bottom="{$body.margin.bottom} +
 {$cropmarks.bleeding}"
 margin-top="{$body.margin.top} + {$cropmarks.bleeding}"/>

 <fo:region-before region-name="xsl-region-before-odd-first"
 extent="{$region.before.extent} + {$cropmarks.bleeding}"
 display-align="after"/>
 <fo:region-after region-name="xsl-region-after-odd-first"
 extent="{$region.after.extent} + {$cropmarks.bleeding}"
 display-align="before"
 />
 <fo:region-start region-name="xsl-region-start-odd-first"
 extent="{$tab.width} + {$cropmarks.bleeding}"
 display-align="after"/>
 <fo:region-end region-name="xsl-region-end-odd-first"
 extent="{$tab.width} + {$cropmarks.bleeding}"/>
 </fo:simple-page-master>

 <fo:simple-page-master master-name="tabbed-body-odd"
 page-width="{$page.width}"
 page-height="{$page.height}"
 margin-top="{$page.margin.top}"
 margin-bottom="{$page.margin.bottom}"
 margin-left="{$page.margin.outer}"
 margin-right="{$page.margin.inner}">
 <fo:region-body region-name="xsl-region-body"
 margin-left="{$body.margin.inner}"
 margin-right="{$body.margin.outer}"
 margin-bottom="{$body.margin.bottom}"
 margin-top="{$body.margin.top}"/>
 <fo:region-before region-name="xsl-region-before-odd"
 extent="{$region.before.extent}"
 display-align="after"/>
 <fo:region-after region-name="xsl-region-after-odd"
 extent="{$region.after.extent}"
 display-align="before"
 />
 <fo:region-start region-name="xsl-region-start-odd"
 extent="{$tab.width}" display-align="after"/>
 <fo:region-end region-name="xsl-region-end-odd" extent="{$tab.width}"/>
 </fo:simple-page-master>

 <fo:simple-page-master master-name="tabbed-body-even"
 page-width="{$page.width}"
 page-height="{$page.height}"
 margin-top="{$page.margin.top}"
 margin-bottom="{$page.margin.bottom}"
 margin-left="{$page.margin.outer}"
 margin-right="{$page.margin.inner}">
 <fo:region-body region-name="xsl-region-body"
 margin-left="{$body.margin.inner}"
 margin-right="{$body.margin.outer}"
 margin-bottom="{$body.margin.bottom}"
 margin-top="{$body.margin.top}"/>
 <fo:region-before region-name="xsl-region-before-even"
 extent="{$region.before.extent}"
 display-align="after"/>
 <fo:region-after region-name="xsl-region-after-even"
 extent="{$region.after.extent}"
 display-align="before"
 />
 <fo:region-start region-name="xsl-region-start-even"
 extent="{$tab.width}"/>
 <fo:region-end region-name="xsl-region-end-even"
 extent="{$tab.width}" display-align="after"/>
 </fo:simple-page-master>


 <fo:simple-page-master master-name="tabbed-body-even-last"
 page-width="{$page.width}"
 page-height="{$page.height}"
 margin-top="{$page.margin.top}"
 margin-bottom="{$page.margin.bottom}"
 margin-left="{$page.margin.outer}"
 margin-right="{$page.margin.inner}">
 <fo:region-body region-name="xsl-region-body"
 margin-left="{$body.margin.inner}"
 margin-right="{$body.margin.outer}"
 margin-bottom="{$body.margin.bottom}"
 margin-top="{$body.margin.top}"/>
 <fo:region-before region-name="xsl-region-before-even-last"
 extent="{$region.before.extent}"
 display-align="after"/>
 <fo:region-after region-name="xsl-region-after-even-last"
 extent="{$region.after.extent}"
 display-align="before"
 />
 <fo:region-start region-name="xsl-region-start-even-last"
 extent="{$tab.width}"/>
 <fo:region-end region-name="xsl-region-end-even-last"
 extent="{$tab.width}" display-align="after"/>
 </fo:simple-page-master>

 <fo:page-sequence-master master-name="tabbed-back">
 <fo:repeatable-page-master-alternatives>
 <fo:conditional-page-master-reference
 master-reference="tabbed-back-even-last"
 odd-or-even="even"
 page-position="last"/>
 <fo:conditional-page-master-reference
 master-reference="tabbed-back-odd-first"
 odd-or-even="odd"
 page-position="first"/>
 <fo:conditional-page-master-reference master-reference="tabbed-back-odd"
 odd-or-even="odd"/>
 <fo:conditional-page-master-reference master-reference="tabbed-back-even"
 odd-or-even="even"/>
 </fo:repeatable-page-master-alternatives>
 </fo:page-sequence-master>

 <fo:page-sequence-master master-name="tabbed-body">
 <fo:repeatable-page-master-alternatives>
 <fo:conditional-page-master-reference
 master-reference="tabbed-body-odd-first"
 odd-or-even="odd"
 page-position="first"/>
 <fo:conditional-page-master-reference
 master-reference="tabbed-body-even-last"
 odd-or-even="even"
 page-position="last"/>
 <fo:conditional-page-master-reference master-reference="tabbed-body-odd"
 odd-or-even="odd"/>
 <fo:conditional-page-master-reference
 odd-or-even="even">
 <xsl:attribute name="master-reference">
   <xsl:choose>
      <xsl:when test="$double.sided != 0">tabbed-body-even</xsl:when>
      <xsl:otherwise>tabbed-body-odd</xsl:otherwise>
   </xsl:choose>
 </xsl:attribute>
 </fo:conditional-page-master-reference>
 </fo:repeatable-page-master-alternatives>
 </fo:page-sequence-master>

</xsl:template>

</xsl:stylesheet>