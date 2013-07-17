<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Contains all parameters for XSL-FO.
    (Sorted against the list in "Part 2. FO Parameter Reference" in
    the DocBook XSL Stylesheets User Reference, see link below)

    See Also:
    * http://docbook.sourceforge.net/release/xsl/current/doc/fo/index.html

  Author(s):  Stefan Knorr <sknorr@suse.de>
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
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

<!--
    How this property list works:

  + there a number of different defined properties (explained below), each may
    be different for every language, thus all properties are prefixed with a
    language name and then a dot (eg. ar. for Arabic properties)
  + the language name is the same as the one used in the the l10n folder and the
    DocBook source files themselves
  + "western" properties function as the fallback whenever a certain property
    does not exist for a certain language
  + the format of properties is
        lang.property = value;
    (make sure to add a space around each side of the equal sign; make sure
    there is a semicolon directly after the last character of each property - do
    not add a space!)
  + you may reference other properties by using either of the two lines below:
        lang.property *use other-property; # from the same language
        lang.property *use other_lang.other-property; # from another language
  + XEP does not like spaces in font names, thus all fonts containing any must
    be listed twice: normal (for FOP), with the name set up in the XEP
    configuration file (for XEP)


    Valid property names (unprefixed):

  + serif: serif font stack, used for text
  + sans: sans-serif font stack, used for headlines, etc.
  + mono: monospace font stack used for command line output, etc.
  + enable-bold: some non-Latin writing systems don't support emboldening text,
    set to "0" in such a case
    particularly well – e.g. in Chinese, some characters may become unreadable
  + enable-serif-semibold/enable-sans-semibold/enable-mono-semibold: set to "1",
    if the chosen font has a semi-bold (600) weight and you want to use it
  + enable-italic: many non-Latin writing systems don't support italicising
    text, set to "0" in such a case
  + fontsize-adjust: uniformly scale the defined standard font sizes, to adjust
    e.g. for greater character complexity in some languages, by setting this to
    a value like "1.3"
  + sans-xheight-adjust: to adjust the font size of the sans-serif font relative
    to the serif font, e.g. set this to the value "0.9", if the sans-serif needs
    to be displayed at 90 % of its original size to make the size of lower-case
    Latin/Cyrillic characters match those of the serif
  + mono-xheight-adjust: to adjust the font size of the monospace font relative
    to the serif font, e.g. set this to the value "0.9", if the monospace needs
    to be displayed at 90 % of its original size to make the size of lower-case
    Latin/Cyrillic characters match those of the serif
  + base-lineheight: set the basic line height for running text
  + sans-lineheight-adjust: to adjust the line height of the sans-serif font to
    match the serif font line height
  + mono-lineheight-adjust: to adjust the line height of the monospace font to
    match the serif font line height

-->


<xsl:param name="l10n.propertylists">
western.serif = 'Charis SIL', CharisSIL, serif;
western.sans = 'Open Sans', OpenSans, sans-serif;
western.mono = 'DejaVu Sans Mono', DejaVuSansMono, monospace;
western.enable-bold = 1;
western.enable-serif-semibold = 0;
western.enable-sans-semibold = 1;
western.enable-mono-semibold = 0;
western.enable-italic = 1;
western.fontsize-adjust = 1;
western.sans-xheight-adjust = 0.916;
western.mono-xheight-adjust = 0.895;
western.base-lineheight = 1.5;
western.sans-lineheight-adjust = 1.31;
western.mono-lineheight-adjust = 1.64;

# Kufic fonts are regarded as rather unreadable, so only use a Naskh (roughly: serif) font.
ar.serif = Amiri, serif;
ar.sans *use serif;
# There don't seem to be any Arabic monospace fonts.
ar.mono = 'DejaVu Sans Mono', DejaVuSansMono, Amiri, monospace;
ar.enable-bold = 1;
ar.enable-serif-semibold = 0;
ar.enable-sans-semibold = 0;
ar.enable-mono-semibold = 0;
ar.enable-italic = 0;
ar.fontsize-adjust = 1;
ar.sans-xheight-adjust = 1;
ar.mono-xheight-adjust = 0.755;
ar.base-lineheight = 0.9;
ar.sans-lineheight-adjust = 1;
ar.mono-lineheight-adjust = 2.581;

ja.serif = IPAPMincho, serif;
ja.sans = IPAPGothic, sans-serif;
ja.mono = 'DejaVu Sans Mono', DejaVuSansMono, 'WenQuanYi Micro Hei Mono', WenQuanYiMicroHeiMono, monospace;
ja.enable-bold = 0;
ja.enable-serif-semibold = 0;
ja.enable-sans-semibold = 0;
ja.enable-mono-semibold = 0;
ja.enable-italic = 0;
ja.fontsize-adjust = 1;
ja.sans-xheight-adjust = 0.99;
ja.mono-xheight-adjust = 0.89;
ja.base-lineheight = 1.5;
ja.sans-lineheight-adjust = 1.03;
ja.mono-lineheight-adjust = 1.44;

ko.serif = NanumMyeongjo, serif;
# Despite its name, NanumGothic doesn't really match Myeongjo in many ways, thus always use the serif font
ko.sans *use serif;
ko.mono = 'DejaVu Sans Mono', DejaVuSansMono, 'WenQuanYi Micro Hei Mono', WenQuanYiMicroHeiMono, monospace;
ko.enable-bold = 1;
ko.enable-serif-semibold = 0;
ko.enable-sans-semibold = 0;
ko.enable-mono-semibold = 0;
ko.enable-italic = 0;
ko.fontsize-adjust = 1;
ko.sans-xheight-adjust = 1;
ko.mono-xheight-adjust = 0.83;
ko.base-lineheight = 1.5;
ko.sans-lineheight-adjust = 1;
ko.mono-lineheight-adjust = 1.44;

# Simplified Chinese is most often printed as sans-serif, so use that.
zh_cn.serif *use sans;
zh_cn.sans = 'WenQuanYi Micro Hei', WenQuanYiMicroHei, sans-serif;
zh_cn.mono = 'DejaVu Sans Mono', DejaVuSansMono, 'WenQuanYi Micro Hei Mono', WenQuanYiMicroHeiMono, monospace;
zh_cn.enable-bold = 0;
zh_cn.enable-serif-semibold = 0;
zh_cn.enable-sans-semibold = 0;
zh_cn.enable-mono-semibold = 0;
zh_cn.enable-italic = 0;
zh_cn.fontsize-adjust = 1;
zh_cn.sans-xheight-adjust = 1;
zh_cn.mono-xheight-adjust = 1;
zh_cn.base-lineheight = 10.75;
zh_cn.sans-lineheight-adjust = 1;
zh_cn.mono-lineheight-adjust = 1.04;

# Traditional Chinese apparently is almost always printed as serif (the exception being on-screen).
zh_tw.serif = 'AR PL UMing TW', ARPLUMingTW, serif;
zh_tw.sans *use serif;
zh_tw.mono = 'DejaVu Sans Mono', DejaVuSansMono, 'WenQuanYi Micro Hei Mono', WenQuanYiMicroHeiMono, monospace;
zh_tw.enable-bold = 0;
zh_tw.enable-serif-semibold = 0;
zh_tw.enable-sans-semibold = 0;
zh_tw.enable-mono-semibold = 0;
zh_tw.enable-italic = 0;
zh_tw.fontsize-adjust = 1.25;
zh_tw.sans-xheight-adjust = 1;
zh_tw.mono-xheight-adjust = 0.781;
zh_tw.base-lineheight = 1.5;
zh_tw.sans-lineheight-adjust = 1;
zh_tw.mono-lineheight-adjust = 1.19;
</xsl:param>


<xsl:template name="get.list.property">
  <xsl:param name="property" select="serif"/>
  <xsl:param name="property.type" select="font"/>
  <xsl:param name="property.language"/>
  <xsl:variable name="property.value">
    <xsl:choose>
      <!-- Checks if {$document.language}.{$property} (dl.p) is in the list at
           all, if it is, it uses the string after dl.p_, and then cuts off
           everything after the next ; .
           If it isn't, it tries again but this time replacing dl with western.
           If that doesn't work, it fails. -->
      <xsl:when test="$property.language != '' and
                      contains($l10n.propertylists, concat($property.language, '.', $property, ' '))">
        <xsl:value-of select="substring-before(substring-after(normalize-space($l10n.propertylists),
                              concat($property.language, '.', $property, ' ')), ';')"/>
      </xsl:when>
      <xsl:when test="$property.language = '' and
                      contains($l10n.propertylists, concat($document.language, '.', $property, ' '))">
        <xsl:value-of select="substring-before(substring-after(normalize-space($l10n.propertylists),
                              concat($document.language, '.', $property, ' ')), ';')"/>
      </xsl:when>
      <xsl:when test="contains($l10n.propertylists, concat('western.', $property, ' '))">
        <xsl:value-of select="substring-before(substring-after(normalize-space($l10n.propertylists),
                              concat('western.', $property, ' ')), ';')"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="starts-with($property.value, '= ')">
      <xsl:value-of select="substring-after($property.value, '= ')"/>
    </xsl:when>
    <xsl:when test="starts-with($property.value, '*use ')">
      <xsl:choose>
        <xsl:when test="contains($property.value, '.')">
          <xsl:call-template name="get.list.property">
            <xsl:with-param name="property" select="substring-after($property.value, '.')"/>
            <xsl:with-param name="property.type" select="$property.type"/>
            <xsl:with-param name="property.language"
              select="substring-before(substring-after($property.value, '*use '), '.')"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$property.language != ''">
          <xsl:call-template name="get.list.property">
            <xsl:with-param name="property" select="substring-after($property.value, '*use ')"/>
            <xsl:with-param name="property.type" select="$property.type"/>
            <xsl:with-param name="property.language" select="$property.language"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="get.list.property">
            <xsl:with-param name="property" select="substring-after($property.value, '*use ')"/>
            <xsl:with-param name="property.type" select="$property.type"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>Could not find value for property <xsl:value-of select="$property"/>. Expected a <xsl:value-of select="$property.type"/>.</xsl:message>
      <xsl:choose>
        <xsl:when test="$property.type = 'font'">serif</xsl:when>
        <xsl:otherwise><!-- type=number -->1</xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
