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
  xmlns:svg="http://www.w3.org/2000/svg">


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
    <fo:instream-foreign-object content-height="0.1em">
      <svg:svg xmlns:svg="http://www.w3.org/2000/svg" width="30" height="7">
        <svg:path
           d="m 5.35,1e-5 c 0,0.97 0,1.94 0,2.91 C 5.89,2.15 5.6,1.67 7.04,2.75 6.39,1.84 6.16,2.09 6.89,0.85 5.25,2.32 5.95,1.32 5.35,10e-6 z m 2.14,0 c -0.2,1.12 0.98,-0.18 0,0 z M 15.38,0.08 c 0,0.97 -0.25,2.72 0.1,2.82 0.55,-2.64 0.79,-1.03 1.34,0.03 C 17.22,1.9 16.47,0.87 15.69,0.95 15.71,0.7 15.86,-0.12 15.38,0.08 z M 27.33,10e-6 c 0,0.97 0,1.94 0,2.92 0.96,-0.95 0.25,-2.82 0,-2.92 z m 2.33,0 C 29.62,1.81 26.57,2.45 29.43,2.82 29.88,2.96 30.29,0.76 29.65,10e-6 z M 14.34,0.25 C 14.2,1.07 14.05,2.71 14.88,2.95 14.97,2.33 14.1,1.3 15.05,1 14.46,1 14.97,0.06 14.34,0.25 z M 0.36,2.84 C 1.09,0.25 0.77,2.07 1.65,2.66 1.65,1.46 2.25,1.2 2.64,2.7 3.86,1.61 -0.61,-1.75 0.36,2.84 z M 4.07,0.94 C 4.48,1.66 1.89,3.3 4.32,2.78 5.44,3.43 4.58,1.4 4.57,0.94 3.35,0.18 2.37,1.54 4.07,0.94 z M 8.49,2.83 C 9.57,-0.93 9.65,3.25 10.1,2.48 10.53,-0.25 7.72,0.9 8.49,2.83 z m 3.55,0.07 C 12.23,4.15 9.91,2.75 11.05,3.8 12.68,4.07 12.42,1.91 12.33,0.88 9.62,0.19 10.15,3.66 12.04,2.9 z M 18.42,0.77 C 15.84,1.64 19.2,3.98 18.68,2.52 17.9,2.78 17.55,1.67 18.55,2.04 19.9,2.22 19.43,0.74 18.42,0.77 z m 6.19,0 C 23.39,0.72 23.39,2.6 24.35,3.0 25.82,3.41 26.08,0.78 24.62,0.77 z m 2.23,0 C 25.91,0.76 25.6,1.59 25.82,2.4 26.16,4.55 26.01,1.39 26.86,0.77 z M 7.49,0.82 c 0,0.7 0,1.39 0,2.09 0.73,-0.74 0.54,-2.01 0,-2.09 z m 13.1,0 C 21.7,5.4 21.81,0.28 22.25,2.18 22.17,3.34 23.34,2.6 23.14,1.86 23.11,-0.81 22.74,3.28 22.46,1.73 22.3,0.53 21.69,1.52 21.35,2.1 21.3,1.76 21.07,0.73 20.6,0.82 z m -9.18,0.24 c 2.35,1.97 -1.97,2.23 0,0 z m 7,0 c 1.96,1.16 -1.81,0.47 0,0 z m 6.19,0 c 1.74,2.18 -1.76,2.02 0,0 z m 4.92,0.14 c 0.63,1.9 -2.25,1.56 0,0 z M 4.44,1.87 c -0.2,1.57 -1.68,0.57 0,0 z M 3.51,3.19 C 3.21,5.5 3.3,5.61 4.07,6.06 6.81,5.3 3.92,5.02 3.51,3.19 z M 17.04,3.22 c 0,0.97 0,1.94 0,2.91 0.97,-0.95 0.3,-2.63 0,-2.91 z M 7.99,3.47 C 7.81,4.3 7.78,5.74 8.45,6.16 8.68,5.52 7.88,4.46 8.68,4.07 7.97,4.23 8.66,3.23 7.99,3.47 z m 1.16,0 C 8.95,4.32 9,5.6 9.53,6.18 9.75,5.7 9.3,4.32 9.8,4.11 9.3,3.94 9.54,3.45 9.15,3.47 z M 0.71,4.3 C 2.34,5.0 -1.94,6.2 1.6,6.13 2.3,5.9 1.6,4.54 1.45,4.04 0.28,3.47 -0.16,5.5 0.71,4.3 z M 6.54,3.96 C 3.43,6.05 8.32,6.54 6.88,5.69 6.23,6.34 5.5,5.02 6.49,5.23 7.9,5.48 7.75,4.06 6.54,3.96 z m 4.5,0 C 7.74,5.46 12.32,6.94 11.37,5.69 10.72,6.34 10.0,5.01 10.997102,5.24 12.39,5.47 12.24,4.05 11.03,3.96 z m 2.71,0.08 c -1.13,0.11 -1.49,0.28 -1.34,1.53 0.33,2.02 0.1,-0.99 1.34,-1.53 z M 15.75,3.96 C 14.62,4.08 14.84,4.57 14.74,7 15.16,5.2 18.41,5.64 15.75,3.96 z m 2.89,0.3 C 20.01,4.71 18.02,4.94 17.89,5.42 17.71,6.62 20.43,6.43 19.57,5.22 19.07,2.36 17.03,5.17 18.64,4.26 z m 3.11,1.66 C 20.75,6.26 19.84,4.99 20.9,4.48 21.4,4.22 22.2,5.08 21.6,4.17 18.91,3.77 20.31,7.43 21.77,5.92 z M 23.11,3.96 c -3.08,0.86 1.13,3.59 0.58,1.76 -0.94,0.4 -1.61,-0.7 -0.62,-0.48 1.4,0.22 1.24,-1.19 0.04,-1.29 z M 3.98,4.58 c 2.08,1.98 -1.33,1.11 0,0 z M 6.54,4.3 c 2.21,0.78 -1.94,1.01 0,0 z m 4.5,0 c 2.32,0.58 -2.24,1.16 0,0 z m 4.59,-0.01 c 1.92,1.59 -1.76,1.58 0,0 z M 23.11,4.3 c 2.27,0.94 -2.09,0.75 0,0 z M 1.41,5.1 c 0.38,1.61 -1.84,0.63 0,0 z m 17.83,0 c 1.04,1.64 -2.78,0.53 0,0 z m 5.28,0.61 c -0.2,1.15 1.12,-0.2 0,0 z"/>
        </svg:svg>
    </fo:instream-foreign-object>
  </xsl:template>

</xsl:stylesheet>
