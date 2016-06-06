<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Creates "page" XML output file which is compatible with
     project Mallard (see http://projectmallard.org).

   Parameters:
     * packagename: Needed for Page format of the package name
       (default: @PACKAGENAME@)
     * generate.xml-model.pi: Creates the PI <?xml-model href="..."
       type="application/relax-ng-compact-syntax"?>.
       This is useful for validation with RELAX NG and oXygen.

   Input:
     DocBook 4, DocBook 5, or Novdoc document

   Output:
     Page XML output according to the RELAX NG schema from
     http://projectmallard.org/1.0/mallard-1.0.rnc

   Note:
     If an article or book does NOT contain an @id/@xml:id, it won't be
     included in the output format. In this case, the stylesheet
     prints a warning.

     Copyright (C) 2012-2015 SUSE Linux GmbH

-->
<!DOCTYPE xsl:stylesheet [
  <!ENTITY lowercase "'abcdefghijklmnopqrstuvwxyz'">
  <!ENTITY uppercase "'ABCDEFGHIJKLMNOPQRSTUVWXYZ'">
]>
<xsl:stylesheet version="1.0"
  xmlns="http://projectmallard.org/1.0/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xl="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="d xl">

  <xsl:output method="xml" indent="yes"/>

  <xsl:param name="packagename">@PACKAGENAME@</xsl:param>
  <xsl:param name="generate.xml-model.pi" select="1"/>

  <xsl:template name="create-info">
    <xsl:variable name="node" select="local-name(.)"/>

    <info>
      <link type="guide" xref="index" group="{$packagename}"/>
      <desc>
        <xsl:choose>
          <xsl:when test="$node = 'set'">
            <xsl:apply-templates
              select="(book|d:book|d:article)[1]"
              mode="setdesc"/>
          </xsl:when>
          <xsl:when test="$node = 'book'">
            <xsl:apply-templates
              select="(appendix|article|chapter|glossary|part|preface|reference|
                      d:appendix|d:article|d:chapter|d:glossary|d:part|d:preface|
                      d:reference)[1]"
              mode="bookdesc"/>
          </xsl:when>
          <xsl:when test="$node = 'article'">
            <!-- Articles are usually single pages anyway. -->
            <xsl:apply-templates
              select="."
              mode="artdesc"/>
          </xsl:when>
        </xsl:choose>
      </desc>
    </info>
  </xsl:template>

  <xsl:template name="warning">
    <xsl:message>
      <xsl:text>Warning: Missing @id/@xml:id in </xsl:text>
      <xsl:value-of select="local-name()"/>
      <xsl:text>, skipped </xsl:text>
      <xsl:value-of select="(*[contains(local-name(),'info')]/title|title|d:info/d:title|d:title)[1]"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="/">
    <xsl:if test="$generate.xml-model.pi != 0">
      <xsl:processing-instruction name="xml-model"
      >href="mallard-1.0.rnc" type="application/relax-ng-compact-syntax"</xsl:processing-instruction>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
    <page type="guide" id="{$packagename}">
      <xsl:apply-templates/>
    </page>
  </xsl:template>

  <xsl:template match="/*">
    <!-- FIXME? This template currently matches "article" too. -->
    <xsl:message terminate="yes">ERROR: Mallard page creation: Unknown root element.</xsl:message>
   </xsl:template>

 <xsl:template match="/set|/d:set|/book|/d:book|/article|/d:article">
    <xsl:call-template name="create-info"/>
    <title>
      <xsl:apply-templates select="(*[contains(local-name(),'info')]/title|title|d:info/d:title|d:title)[1]"/>
    </title>
    <p>
      <xsl:choose>
        <xsl:when test="local-name(.) = 'set' and
                        *[contains(local-name(),'info')]/productname|d:info/d:productname">
          <xsl:text>The documentation for </xsl:text>
          <xsl:value-of select="normalize-space((*[contains(local-name(),'info')]/productname|d:info/d:productname)[1])"/>
          <xsl:if test="*[contains(local-name(),'info')]/productnumber|d:info/d:productnumber">
            <xsl:text> </xsl:text>
            <xsl:value-of select="normalize-space((*[contains(local-name(),'info')]/productnumber|d:info/d:productnumber)[1])"/>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space((*[contains(local-name(),'info')]/title|title|d:info/d:title|d:title)[1])"/>
        </xsl:otherwise>
      </xsl:choose>
      consists of:
    </p>
    <xsl:choose>
      <xsl:when test="local-name(.) = 'set'">
        <!-- We select:
        + line 1,2: books without articles (unless there are also chapters
          or similar elements on the same structural level as the article)
        + line 3,4: article included in books (same caveat as above)
        + line 5: articles directly within the set (DocBook 5 only) -->
        <xsl:apply-templates
          select="book[not(article) or (article and (chapter|glossary|part|preface|reference))]|
                  d:book[not(d:article) or (d:article and (d:chapter|d:glossary|d:part|d:preface|d:reference))]|
                  book[article and not(chapter|glossary|part|preface|reference)]/article|
                  d:book[d:article and not(d:chapter|d:glossary|d:part|d:preface|d:reference)]/d:article|
                  d:article"
          mode="summary"/>
      </xsl:when>
      <xsl:when test="local-name(.) = 'book'">
        <xsl:apply-templates
          select="appendix|article|chapter|glossary|part|preface|reference|
                  d:appendix|d:article|d:chapter|d:glossary|d:part|d:preface|
                  d:reference"
          mode="summary"/>
      </xsl:when>
      <xsl:when test="local-name(.) = 'article'">
        <xsl:apply-templates
          select="."
          mode="summary"/>
      </xsl:when>
    </xsl:choose>
   </xsl:template>

  <!-- Create a "desc:" a short link list to be displayed below a link to our
  page on the global overview page of the system help (i.e. not on this page
  itself). -->

  <xsl:template match="book|article|d:book|d:article" mode="setdesc">
    <xsl:param name="count" select="0"/>

    <xsl:variable name="separator" select="', '"/>
    <xsl:variable name="id" select="(./@id|./@xml:id)[1]"/>

    <xsl:choose>
      <xsl:when test="not(@id|@xml:id)">
        <xsl:call-template name="warning"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$count &gt; 0">
          <xsl:value-of select="$separator"/>
        </xsl:if>
        <xsl:text>&#10;</xsl:text>
        <link href="help:{$packagename}/{$id}">
          <xsl:apply-templates select="(*[contains(local-name(), 'info')]/title|title|d:info/d:title|d:title)[1]"/>
        </link>
      </xsl:otherwise>
    </xsl:choose>

    <!-- FIXME: set/set is not handled (though we do not use that). -->
    <xsl:choose>
      <!-- Limit to a maximum of five entries, to match Yelp's style and
      to avoid having a link list that is too long. -->
      <xsl:when test="$count &gt; 3 and
        ( following-sibling::book[@id]|following-sibling::d:book[@xml:id]|
          following-sibling::article[@id]|following-sibling::d:article[@xml:id])">
        <xsl:text>…</xsl:text>
      </xsl:when>
      <!-- Handle set/book/article -->
      <xsl:when
        test="following-sibling::*[1][self::book and article and not(chapter|glossary|part|preface|reference)]|
              following-sibling::*[1][self::d:book and d:article and not(d:chapter|d:glossary|d:part|d:preface|d:reference)]">
        <!-- FIXME: Currently this only works as long as there is only one book
        of articles and it is the last book. -->
        <xsl:apply-templates
          select="(following-sibling::book[1]/article[1]|
                  following-sibling::d:book[1]/d:article[1])[1]"
          mode="setdesc">
          <xsl:with-param name="count" select="$count + 1"/>
        </xsl:apply-templates>
      </xsl:when>
      <!-- Handle set/book and set/article -->
      <xsl:when
        test="following-sibling::*[1][self::book or self::article or
                                      self::d:book or self::d:article]">
        <xsl:apply-templates
          select="following-sibling::*[1][self::book or self::article or
                                          self::d:book or self::d:article]"
          mode="setdesc">
          <xsl:with-param name="count" select="$count + 1"/>
        </xsl:apply-templates>
      </xsl:when>
      <!-- Allow for set/set (but ignore those (FIXME)). -->
      <xsl:when test="following-sibling::*">
        <xsl:apply-templates
          select="following-sibling::*[1]"
          mode="setdesc">
          <xsl:with-param name="count" select="$count"/>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="set|d:set" mode="setdesc">
    <xsl:param name="count" select="0"/>
    <xsl:apply-templates
      select="following-sibling::*[1]"
      mode="setdesc">
      <xsl:with-param name="count" select="$count"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template
    match=" appendix|article|chapter|part|preface|glossary|reference|
            d:appendix|d:article|d:chapter|d:part|d:preface|d:glossary|
            d:reference"
    mode="bookdesc">
    <xsl:param name="count" select="0"/>

    <xsl:variable name="separator" select="', '"/>
    <xsl:variable name="id" select="(./@id|./@xml:id)[1]"/>

    <xsl:choose>
      <xsl:when test="not(@id|@xml:id)">
        <xsl:call-template name="warning"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$count &gt; 0">
          <xsl:value-of select="$separator"/>
        </xsl:if>
        <xsl:text>&#10;</xsl:text>
        <link href="help:{$packagename}/{$id}">
          <xsl:apply-templates
            select="(*[contains(local-name(), 'info')]/title|title|d:info/d:title|d:title)[1]"/>
        </link>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
      <!-- Limit to a maximum of five entries, to match Yelp's style and
      to avoid having a link list that is too long. -->
      <xsl:when
        test="$count &gt; 3 and
              following-sibling::*[1][self::article or self::chapter or
                                      self::preface or self::part or
                                      self::appendix[not(@role='legal')] or
                                      self::glossary or self::reference or
                                      self::d:article or self::d:chapter or
                                      self::d:preface or self::d:part or
                                      self::d:appendix[not(@role='legal')] or
                                      self::d:glossary or self::d:reference]">
        <xsl:text>…</xsl:text>
      </xsl:when>
      <!-- Handle book contents -->
      <xsl:when
        test="following-sibling::*[1][self::article or self::chapter or
                                      self::preface or self::part or
                                      self::appendix[not(@role='legal')] or
                                      self::glossary or self::reference or
                                      self::d:article or self::d:chapter or
                                      self::d:preface or self::d:part or
                                      self::d:appendix[not(@role='legal')] or
                                      self::d:glossary or self::d:reference]">
        <xsl:apply-templates
          select="following-sibling::*[1][self::article or self::chapter or
                                          self::preface or self::part or
                                          self::appendix[not(@role='legal')] or
                                          self::glossary or self::reference or
                                          self::d:article or self::d:chapter or
                                          self::d:preface or self::d:part or
                                          self::d:appendix[not(@role='legal')] or
                                          self::d:glossary or self::d:reference]"
          mode="bookdesc">
          <xsl:with-param name="count" select="$count + 1"/>
        </xsl:apply-templates>
      </xsl:when>
      <!-- Allow for book/{acknowledgements,appendix[@role=legal],bibliography,
      colophon,dedication,index,toc} (but ignore those - which is correct
      behavior here) -->
      <xsl:when test="following-sibling::*">
        <xsl:apply-templates
          select="following-sibling::*[1]"
          mode="bookdesc">
          <xsl:with-param name="count" select="$count"/>
        </xsl:apply-templates>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
 
  <xsl:template
    match=" acknowledgements|appendix[@role='legal']|bibliography|
            colophon|dedication|index|lot|setindex|toc|
            d:acknowledgements|d:appendix[@role='legal']|d:bibliography|
            d:colophon|d:dedication|d:index|d:toc"
    mode="bookdesc">
    <xsl:param name="count" select="0"/>
    <xsl:apply-templates
      select="following-sibling::*[1]"
      mode="bookdesc">
      <xsl:with-param name="count" select="$count"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="article|d:article" mode="artdesc">
    <xsl:variable name="id" select="(./@id|./@xml:id)[1]"/>

    <xsl:choose>
      <xsl:when test="not(@id|@xml:id)">
        <xsl:call-template name="warning"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#10;</xsl:text>
        <link href="help:{$packagename}/{$id}">
          <xsl:apply-templates
            select="(*[contains(local-name(), 'info')]/title|title|d:info/d:title|d:title)[1]"/>
        </link>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
 
  <xsl:template match="*|d:*" mode="setdesc"/>
  <xsl:template match="*|d:*" mode="bookdesc"/>

  <!-- fill the page with "sections" -->
  <xsl:template
    match=" book[@id]|d:book[@xml:id]|
            article[@id]|d:article[@xml:id]|
            chapter[@id]|part[@id]|
            d:chapter[@xml:id]|d:part[@xml:id]|
            sect1[@id]|section[@id]|simplesect[@id]|
            d:sect1[@xml:id]|d:section[@xml:id]|d:simplesect[@xml:id]"
    mode="summary">
    <xsl:param name="node" select="."/>
    <xsl:variable name="id" select="($node/@id|$node/@xml:id)[1]"/>
    <section id="{$id}">
      <title>
        <link href="help:{$packagename}/{$id}">
          <xsl:apply-templates select="(*[contains(local-name(), 'info')]/title|title|d:info/d:title|d:title)[1]"/>
         </link>
      </title>
      <xsl:choose>
        <xsl:when test="*/abstract|*/highlights|*/*/abstract|*/*/highlights|d:info/d:abstract|*/d:info/d:abstract">
          <xsl:apply-templates select="(*/abstract|*/highlights|*/*/abstract|*/*/highlights|d:info/d:abstract|*/d:info/d:abstract)[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="para">
            <xsl:apply-templates
              select="(*/para[not(ancestor::legalnotice)]|
                      */*/para[not(ancestor::legalnotice)]|
                      */d:para[not(ancestor::d:legalnotice)]|
                      */*/d:para[not(ancestor::d:legalnotice)])[1]"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="string-length($para) &lt; 250">
              <xsl:copy-of select="$para"/>
            </xsl:when>
            <xsl:otherwise>
              <p>
                <!-- 248 characters + the end of the current word + ellipsis -->
                <xsl:value-of
                 select="concat(substring($para, 1, 248),
                         substring-before(substring($para, 249, string-length($para)), ' '))"/>
               <xsl:text>…</xsl:text>
             </p>
           </xsl:otherwise>
         </xsl:choose>
       </xsl:otherwise>
     </xsl:choose>
    </section>
  </xsl:template>

  <xsl:template
    match=" appendix[@id]|glossary[@id]|preface[@id]|reference[@id]|
            d:appendix[@xml:id]|d:glossary[@xml:id]|d:preface[@xml:id]|
            d:reference[@xml:id]|
            refentry[@id]|d:refentry[@xml:id]"
    mode="summary">
    <xsl:param name="node" select="."/>
    <xsl:variable name="id" select="($node/@id|$node/@xml:id)[1]"/>

    <section id="{$id}">
      <title>
        <link href="help:{$packagename}/{$id}">
          <xsl:apply-templates select="(*[contains(local-name(), 'info')]/title|title|d:info/d:title|d:title)[1]"/>
         </link>
      </title>
    </section>
  </xsl:template>

  <xsl:template
    match=" book[not(@id)]|d:book[not(@xml:id)]|
            article[not(@id)]|d:article[not(@xml:id)]|
            appendix[not(@id)]|chapter[not(@id)]|glossary[not(@id)]|
            part[not(@id)]|preface[not(@id)]|reference[not(@id)]|
            d:appendix[not(@xml:id)]|d:chapter[not(@xml:id)]|
            d:glossary[not(@xml:id)]|d:part[not(@xml:id)]|
            d:preface[not(@xml:id)]|d:reference[not(@xml:id)]|
            refentry[not(@id)]|sect1[not(@id)]|
            section[not(@id)]|simplesect[not(@id)]|
            d:refentry[not(@xml:id)]|d:sect1[not(@xml:id)]|
            d:section[not(@xml:id)]|d:simplesect[not(@xml:id)]"
    mode="summary">
    <xsl:call-template name="warning"/>
  </xsl:template>

  <!-- Random text styles for the summaries -->
  <xsl:template match="title|d:title">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="abstract|highlights|d:abstract">
    <xsl:apply-templates/>
   </xsl:template>

  <xsl:template match="para|d:para">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="emphasis|d:emphasis">
    <em>
      <xsl:apply-templates/>
    </em>
  </xsl:template>

  <xsl:template match="quote|d:quote">
    <xsl:text>“</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>”</xsl:text>
  </xsl:template>

  <xsl:template match="phrase|d:phrase">
    <!-- Generally, we want phrases to be unhyphenated, but there does
         not seem to be a [style hint](https://wiki.gnome.org/Apps/Yelp/Mallard/Styles)
         for that yet and Yelp does not seem to hyphenate ever, so ...
         lets just add a span. -->
    <span>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="citetitle|d:citetitle">
    <!-- citetitle is often used around our title entities, we just want to
    ignore it here (but not the contained text) -->
     <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="systemitem|package|literal|uri|sgmltag|
                       d:systemitem|d:package|d:literal|d:uri|d:tag">
    <sys><xsl:apply-templates/></sys>
  </xsl:template>

  <xsl:template match="varname|envar|option|replaceable|
                       d:varname|d:envar|d:option|d:replaceable">
    <var><xsl:apply-templates/></var>
  </xsl:template>

  <xsl:template match="command|d:command|systemitem|d:systemitem">
    <cmd><xsl:apply-templates/></cmd>
  </xsl:template>

  <xsl:template match="filename|d:filename">
    <file><xsl:apply-templates/></file>
  </xsl:template>

  <xsl:template match="menuchoice|d:menuchoice">
    <guiseq><xsl:apply-templates/></guiseq>
  </xsl:template>

  <xsl:template
    match=" guimenu|accel|guibutton|guiicon|guilabel|guimenuitem|guisubmenu|
            d:guimenu|d:guibutton|d:guiicon|d:guilabel|d:guimenuitem|d:guisubmenu">
    <gui><xsl:apply-templates/></gui>
  </xsl:template>

  <xsl:template match="keycombo|d:keycombo">
    <keyseq><xsl:apply-templates/></keyseq>
  </xsl:template>

  <xsl:template
    match=" keycap|keycode|keycombo|keysym|menuchoice|mousebutton|
            d:accel|d:keycap|d:keycode|d:keycombo|d:keysym|d:mousebutton">
    <key><xsl:apply-templates/></key>
  </xsl:template>

  <xsl:template match="orderedlist|itemizedlist|d:orderedlist|d:itemizedlist">
    <list>
      <xsl:if test="self::orderedlist|self::d:orderedlist">
        <xsl:attribute name="type">numbered</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </list>
  </xsl:template>

  <xsl:template match="listitem">
    <item>
      <xsl:apply-templates/>
    </item>
  </xsl:template>

  <xsl:template match="ulink|d:link">
    <xsl:variable name="url" select="normalize-space((@url|@xl:href)[1])"/>
    <link href="{$url}">
      <xsl:choose>
        <xsl:when test="normalize-space(.) = ''">
          <xsl:value-of select="$url"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </link>
  </xsl:template>

  <xsl:template match="xref|d:xref">
    <xsl:choose>
      <xsl:when test="normalize-space(.) = ''">
        <xsl:value-of select="normalize-space(@linkend)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*|d:*">
    <xsl:message>WARNING: Unknown element "<xsl:value-of select="local-name(.)"/>" was ignored.</xsl:message>
  </xsl:template>

</xsl:stylesheet>
