<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Re-Style admonitions

  Author(s):  Stefan Knorr <sknorr@suse.de>,
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2013, Stefan Knorr, Thomas Schraitle

-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  <!ENTITY % colors SYSTEM "colors.ent">
  <!ENTITY % metrics SYSTEM "metrics.ent">
  %fonts;
  %colors;
  %metrics;
]>
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:date="http://exslt.org/dates-and-times"
  exclude-result-prefixes="date">


<xsl:template match="note|important|warning|caution|tip">
  <xsl:call-template name="graphical.admonition"/>
</xsl:template>

<xsl:template name="admon.symbol">
  <xsl:param name="color" select="'&dark-green;'"/>
  <xsl:param name="node" select="."/>

  <xsl:choose>
    <xsl:when test="local-name($node)='warning' or local-name($node)='caution'">
    <!-- The symbol for these two is currently the same -->
      <svg:svg width="36" height="36">
        <svg:path d="M 18,0 C 8.06,0 0,8.06 0,18 0,27.94 8.06,36 18,36 27.94,36 36,27.94 36,18 36,8.06 27.94,0 18,0 z m 0,7 c 0.62,0 1,0.51 1,1.13 l 0,9.88 1,0 0,-8.53 c 0,-0.62 0.38,-1.13 1,-1.13 0.62,0 1,0.51 1,1.13 L 22,22 l 1,0 0,-4.78 c 0,-0.62 0.29,-1.13 0.91,-1.13 0.62,0 1.09,0.17 1.09,1.13 L 25,22.5 c -8.8e-4,3.6 -3.41,6.5 -7,6.5 -3.59,-9e-4 -7,-2.92 -7,-5.84 l 0,-9.31 c 0,-0.96 0.38,-1.47 1,-1.47 0.62,0 1,0.51 1,1.13 l 0,5.5 1,0 0,-9.53 c -2e-5,-0.62 0.38,-1.13 1,-1.13 0.62,0 1,0.5 1,1.13 L 16,18 17,18 17,8.13 C 17.04,7.51 17.38,7 18,7 z"
          fill="{$color}"/>
      </svg:svg>
    </xsl:when>
    <xsl:when test="local-name($node)='tip'">
      <svg:svg width="36" height="36">
        <svg:path d="M 18,0 C 8.06,0 0,8.06 0,18 0,27.94 8.06,36 18,36 27.94,36 36,27.94 36,18 36,8.06 27.94,0 18,0 z m 0,4.75 c 4.62,0 8.43,3.69 8.38,8.31 -0.052,4.47 -3.11,6.6 -4.19,11.56 l -8.03,2.19 C 14.12,26.35 14.07,25.92 14,25.5 l 4.5,-1.25 -4.78,0 C 12.57,19.55 9.7,17.4 9.66,13.06 9.6,8.44 13.38,4.75 18,4.75 z m -0.88,8.56 -0.41,0.72 -1.97,0 c -1.18,0 -1.39,0.28 -1.19,1 l 1.94,7 c 0.073,0.24 0.31,0.38 0.5,0.38 0.29,0 0.54,-0.16 0.53,-0.5 l -1.88,-6.88 1.47,0 c -0.14,0.24 -0.068,0.58 0.19,0.69 0.47,0.2 0.54,-0.07 0.78,-0.31 0.03,0.12 0.09,0.26 0.22,0.31 0.48,0.19 0.54,-0.07 0.78,-0.31 0.03,0.12 0.11,0.3 0.25,0.34 0.52,0.14 0.51,0.04 0.94,-0.72 l 2.06,0 -1.88,6.88 c 0,0.33 0.25,0.49 0.53,0.5 0.28,0.01 0.45,-0.2 0.5,-0.38 l 1.94,-7 c 0.2,-0.72 0,-1 -1.19,-1 l -1.38,0 C 20.17,13.52 20.12,13.21 19.81,13.13 19.41,13.02 19.27,13.23 19.03,13.47 19.01,13.33 18.96,13.18 18.81,13.13 18.39,12.96 18.27,13.21 18.03,13.47 18.01,13.33 17.97,13.22 17.81,13.13 17.54,12.96 17.24,13.11 17.13,13.31 z M 22,25.69 c -0.07,0.47 -0.1,0.1 -0.13,1.5 l -7.5,2.06 C 14.23,28.75 14.21,28.29 14.19,27.81 z M 21.81,28.25 c 0.029,0.62 -0.18,1.19 -0.44,1.63 l -5.19,1.38 c -0.53,-0.27 -0.99,-0.65 -1.34,-1.13 z"
          fill="{$color}"/>
      </svg:svg>
    </xsl:when>
    <xsl:when test="local-name($node)='important'">
      <svg:svg width="36" height="36">
        <svg:path d="M 18,0 C 8,0 0,8 0,18 0,28 8,36 18,36 28,36 36,28 36,18 36,8 28,0 18,0 z m -2.5,7 5.125,0 -0.75,14.5 -3.625,0 L 15.5,7 z M 18,24 c 0.8,0 1.5,0.25 1.9,0.625 0.45,0.45 0.65,1 0.65,1.9 -10e-6,0.75 -0.25,1.4 -0.65,1.85 C 19.45,28.75 18.8,29 18,29 17.15,29 16.55,28.75 16.1,28.35 15.65,27.9 15.4,27.3 15.4,26.5 c 0,-0.83 0.25,-1.45 0.65,-1.85 C 16.55,24.2 17.15,24 18,24 z"
          fill="{$color}"/>
      </svg:svg>
    </xsl:when>
    <xsl:otherwise>
      <!-- It's a note. (Or something undefined.) -->
      <svg:svg width="36" height="36">
        <svg:path d="M 18,0 C 8.061,0 0,8.058 0,18 0,27.94 8.061,36 18,36 27.942,36 36,27.94 36,18 36,8.058 27.942,0 18,0 z m -3.5,5.125 c 0.266,1.75e-4 0.512,0.0745 0.688,0.25 l 12,12 0.7188,8.625 c -6e-5,0.511 -0.172,1.047 -0.563,1.438 -0.39,0.39 -0.928,0.605 -1.438,0.563 l -8.625,-0.719 -12,-12 c -0.391,-0.391 -0.391,-1.016 0,-1.406 0.383,-0.383 1.03,-0.408 1.438,0 L 18.125,25.313 25.906,26 25.188,18.219 14.5,7.5 l -4.25,4.25 8.813,8.813 1.906,0.5 -0.531,-1.938 -7.375,-7.375 1.438,-1.406 7.75,7.75 0.844,3.063 c 8.9e-5,0.511 -0.204,1.047 -0.594,1.438 -0.39,0.39 -0.895,0.532 -1.406,0.531 L 18,22.344 8.125,12.469 c -0.39,-0.39 -0.39,-1.047 0,-1.438 L 13.781,5.375 C 13.958,5.199 14.234,5.125 14.5,5.125 z"
          fill="{$color}"/>
      </svg:svg>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="admon.symbol.color">
  <xsl:param name="node" select="."/>
  <xsl:choose>
    <xsl:when test="$format.print = 1">
      <xsl:text>&darker-gray;</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="local-name($node)='warning' or
                        local-name($node)='caution'">
          <!-- The symbol for these two is currently the same -->
          <xsl:text>&dark-blood;</xsl:text>
        </xsl:when>
        <xsl:when test="local-name($node)='tip'">
          <xsl:text>&dark-green;</xsl:text>
        </xsl:when>
        <xsl:when test="local-name($node)='important'">
          <xsl:text>&mid-orange;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <!-- It's a note. (Or something undefined.) -->
          <xsl:text>&darker-gray;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="graphical.admonition">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <xsl:variable name="color">
    <xsl:call-template name="admon.symbol.color"/>
  </xsl:variable>
  <!-- <xsl:variable name="graphic.width" select="6.1"/> -->
  <xsl:variable name="graphic.width" select="8"/>

  <fo:block id="{$id}" xsl:use-attribute-sets="graphical.admonition.properties">
    <fo:list-block
      provisional-distance-between-starts="{&columnfragment; + &gutterfragment;}mm"
      provisional-label-separation="&gutter;mm">
      <fo:list-item>
          <fo:list-item-label end-indent="label-end()">
            <fo:block text-align="end" padding-before="1.2mm" padding-after="1.2mm">
              <fo:instream-foreign-object content-width="{$graphic.width}mm">
                <xsl:call-template name="admon.symbol">
                  <xsl:with-param name="color" select="$color"/>
                </xsl:call-template>
              </fo:instream-foreign-object>
            </fo:block>
          </fo:list-item-label>
          <fo:list-item-body start-indent="body-start()">
            <fo:block padding-start="{(&gutter; - 0.75) div 2}mm"
              padding-before="3mm" padding-after="3mm">
              <xsl:if test="$admon.textlabel != 0 or title or info/title">
                <fo:block xsl:use-attribute-sets="admonition.title.properties"
                  color="{$color}">
                  <xsl:apply-templates select="." mode="object.title.markup">
                    <xsl:with-param name="allow-anchors" select="1"/>
                  </xsl:apply-templates>
                </fo:block>
              </xsl:if>
              <fo:block xsl:use-attribute-sets="admonition.properties">
                <xsl:apply-templates/>
              </fo:block>
            </fo:block>
          </fo:list-item-body>
      </fo:list-item>
    </fo:list-block>
  </fo:block>
</xsl:template>

<xsl:template name="name">
    <xsl:variable name="date">
      <xsl:if test="function-available('date:date')">
        <xsl:value-of select="substring(date:date(),6,5)"/>
      </xsl:if>
    </xsl:variable>

    <xsl:if test="$date = '04-01'">
      <fo:inline font-size="0.2em">
        <fo:basic-link external-destination="{$this}">
          <fo:instream-foreign-object content-height="1em">
            <svg:svg width="3000" height="700">
              <svg:path
                 d="m 535,1e-5 c 0,97 0,194 0,291 C 589,215 560,167 704,275 639,184 616,209 689,85 525,232 595,132 535,10e-6 z m 214,0 c -20,112 98,-18 0,0 z M 1538,8 c 0,97 -25,272 10,282 55,-264 79,-103 134,3 C 1722,190 1647,87 1569,95 1571,70 1586,-12 1538,8 z M 2733,10e-6 c 0,97 0,194 0,292 96,-95 25,-282 0,-292 z m 233,0 C 2962,181 2657,245 2943,282 2988,296 3029,76 2965,10e-6 z M 1434,25 C 1420,107 1405,271 1488,295 1497,233 1410,130 1505,100 1446,100 1497,6 1434,25 z M 36,284 C 109,25 77,207 165,266 165,146 225,120 264,270 386,161 -61,-175 36,284 z M 407,94 C 448,166 189,330 432,278 544,343 458,140 457,94 335,18 237,154 407,94 z M 849,283 C 957,-93 965,325 1010,248 1053,-25 772,90 849,283 z m 355,7 C 1223,415 991,275 1105,380 1268,407 1242,191 1233,88 962,19 1015,366 1204,290 z M 1842,77 C 1584,164 1920,398 1868,252 1790,278 1755,167 1855,204 1990,222 1943,74 1842,77 z m 619,0 C 2339,72 2339,260 2435,300 2582,341 2608,78 2462,77 z m 223,0 C 2591,76 2560,159 2582,240 2616,455 2601,139 2686,77 z M 749,82 c 0,70 0,139 0,209 73,-74 54,-201 0,-209 z m 1310,0 C 2170,540 2181,28 2225,218 2217,334 2334,260 2314,186 2311,-81 2274,328 2246,173 2230,53 2169,152 2135,210 2130,176 2107,73 2060,82 z m -918,24 c 235,197 -197,223 0,0 z m 700,0 c 196,116 -181,47 0,0 z m 619,0 c 174,218 -176,202 0,0 z m 492,14 c 63,190 -225,156 0,0 z M 444,187 c -20,157 -168,57 0,0 z M 351,319 C 321,550 330,561 407,606 681,530 392,502 351,319 z M 1704,322 c 0,97 0,194 0,291 97,-95 30,-263 0,-291 z M 799,347 C 781,430 778,574 845,616 868,552 788,446 868,407 797,423 866,323 799,347 z m 116,0 C 895,432 900,560 953,618 975,570 930,432 980,411 930,394 954,345 915,347 z M 71,430 C 234,500 -194,620 160,613 230,590 160,454 145,404 28,347 -16,550 71,430 z M 654,396 C 343,605 832,654 688,569 623,634 550,502 649,523 790,548 775,406 654,396 z m 450,0 C 774,546 1232,694 1137,569 1072,634 1000,501 1100,524 1239,547 1224,405 1103,396 z m 271,8 c -113,11 -149,28 -134,153 33,202 10,-99 134,-153 z M 1575,396 C 1462,408 1484,457 1474,700 1516,520 1841,564 1575,396 z m 289,30 C 2001,471 1802,494 1789,542 1771,662 2043,643 1957,522 1907,236 1703,517 1864,426 z m 311,166 C 2075,626 1984,499 2090,448 2140,422 2220,508 2160,417 1891,377 2031,743 2177,592 z M 2311,396 c -308,86 113,359 58,176 -94,40 -161,-70 -62,-48 140,22 124,-119 4,-129 z M 398,458 c 208,198 -133,111 0,0 z M 654,430 c 221,78 -194,101 0,0 z m 450,0 c 232,58 -224,116 0,0 z m 459,-1 c 192,159 -176,158 0,0 z M 2311,430 c 227,94 -209,75 0,0 z M 141,510 c 38,161 -184,63 0,0 z m 1783,0 c 104,164 -278,53 0,0 z m 528,61 c -20,115 112,-20 0,0 z"/>
              </svg:svg>
          </fo:instream-foreign-object>
        </fo:basic-link>
      </fo:inline>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
