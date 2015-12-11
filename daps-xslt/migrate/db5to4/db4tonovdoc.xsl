<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Transforms DocBook document into Novdoc

   Parameters:
     * createvalid
       Should the output be valid? 1=yes, 0=no
     * menuchoice.menu.separator (default: " > ")
       String to separate menu components in titles (only for
       guimenuitem and guisubmenu)
     * menuchoice.separator (default: "+")
       String to separate menu components in titles
     * rootid
       Process only parts of the document
     * debug.level
       Level what messages are shown (1=only warnings, 2=infos)

   Input:
     DocBook4 document

   Output:
     Novdoc document (subset of DocBook)

   DocBook 5 compatible:
     No, convert your document to DocBook 4 first

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH

-->

<!DOCTYPE xsl:stylesheet
[
  <!ENTITY dbinline "abbrev|acronym|biblioref|citation|
 citerefentry|citetitle|citebiblioid|emphasis|firstterm|
 foreignphrase|glossterm|termdef|footnote|footnoteref|phrase|orgname|quote|
 trademark|wordasword|personname|link|olink|ulink|action|
 application|classname|methodname|interfacename|exceptionname|
 ooclass|oointerface|ooexception|package|command|computeroutput|
 database|email|envar|errorcode|errorname|errortype|errortext|
 filename|function|guibutton|guiicon|guilabel|guimenu|guimenuitem|
 guisubmenu|hardware|interface|keycap|keycode|keycombo|keysym|
 literal|code|constant|markup|medialabel|menuchoice|mousebutton|
 option|optional|parameter|prompt|property|replaceable|
 returnvalue|sgmltag|structfield|structname|symbol|systemitem|uri|
 token|type|userinput|varname|nonterminal|anchor|author|
 authorinitials|corpauthor|corpcredit|modespec|othercredit|
 productname|productnumber|revhistory|remark|subscript|
 superscript|inlinegraphic|inlinemediaobject|inlineequation|
 synopsis|cmdsynopsis|funcsynopsis|classsynopsis|fieldsynopsis|
 constructorsynopsis|destructorsynopsis|methodsynopsis|indexterm|xref">
]>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exslt="http://exslt.org/common"
  version="1.0"
  exclude-result-prefixes="exslt">

  <xsl:import href="../../common/copy.xsl"/>
  <!--<xsl:import href="rootid.xsl"/>-->

  <xsl:output method="xml" indent="yes"
    doctype-public="-//Novell//DTD NovDoc XML V1.0//EN"
    doctype-system="novdocx.dtd"/>

  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="screen"/>

  <!-- ################################################################## -->
  <!-- Parameters                                                         -->

  <!-- Should the output be valid? 1=yes, 0=no -->
  <xsl:param name="createvalid" select="1"/>
  <xsl:param name="menuchoice.menu.separator"> > </xsl:param>
  <xsl:param name="menuchoice.separator">+</xsl:param>
  <xsl:param name="rootid"/>
  <xsl:param name="use.doctype4novdoc" select="0"/>
  <xsl:param name="debug.level" select="4"/>

  <xsl:key name="id" match="*" use="@id|@xml:id"/>

  <!-- ################################################################## -->
  <!-- Suppressed PIs                                                     -->
  <xsl:template match="processing-instruction('xml-stylesheet')"/>


  <!-- ################################################################## -->
  <!-- Suppressed attributes                                              -->

  <!-- Suppressed attributes -->
  <xsl:template match="@continuation"/>
  <xsl:template match="@format"/>
  <xsl:template match="@float"/>
  <xsl:template match="@inheritnum"/>
  <xsl:template match="section/@lang|sect1/@lang"/>
  <xsl:template match="@moreinfo"/>
  <xsl:template match="@significance"/>
  <xsl:template match="@mark"/>
  <xsl:template match="@spacing"/>
  <xsl:template match="*/@status"/>
  <xsl:template match="book/@xml:base"/>
  <xsl:template match="productname/@class"/>
  <xsl:template match="orderedlist/@spacing[. ='normal']"/>
  <xsl:template match="step/@performance[. = 'required']"/>
  <xsl:template match="substeps/@performance[. = 'required']"/>
  <xsl:template match="@rules[. ='all']"/>
  <xsl:template match="@wordsize"/>
  <xsl:template match="screen/@language"/>
  <xsl:template match="filename/@class"/>
  <xsl:template match="literallayout/@class"/>
  <xsl:template match="variablelist/@role"/>

  <!-- ################################################################## -->
  <!-- Suppressed Elements                                                -->
  <xsl:template match="abstract/title"/>
  <xsl:template match="appendixinfo|chapterinfo|prefaceinfo|partinfo"/>
  <xsl:template match="sect1info|sect2info|sect3info|sect4info|sect5info"/>
  <xsl:template match="remark"/>


  <!-- ################################################################## -->
  <!-- Named Templates                                                    -->

  <xsl:template name="message">
    <xsl:param name="text"/>
    <xsl:param name="type"/>
    <xsl:param name="abort" select="0"/>

    <xsl:choose>
      <xsl:when test="$abort != 0">
        <xsl:message terminate="yes">
          <xsl:value-of select="$type"/>
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$text"/>
        </xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:value-of select="$type"/>
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$text"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="fatal">
    <xsl:param name="text"/>
      <xsl:call-template name="message">
        <xsl:with-param name="type">FATAL</xsl:with-param>
        <xsl:with-param name="text" select="$text"/>
        <xsl:with-param name="abort" select="1"/>
      </xsl:call-template>
  </xsl:template>
  <xsl:template name="warn">
    <xsl:param name="text"/>
    <xsl:if test="$debug.level > 1">
      <xsl:call-template name="message">
        <xsl:with-param name="type">WARNING</xsl:with-param>
        <xsl:with-param name="text" select="$text"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template name="info">
    <xsl:param name="text"/>
    <xsl:if test="$debug.level > 2">
      <xsl:call-template name="message">
        <xsl:with-param name="type">INFO</xsl:with-param>
        <xsl:with-param name="text" select="$text"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="getrootname">
    <xsl:choose>
      <xsl:when test="$rootid !=''">
        <xsl:if test="count(key('id',$rootid)) = 0">
          <xsl:message terminate="yes">
            <xsl:text>ID '</xsl:text>
            <xsl:value-of select="$rootid"/>
            <xsl:text>' not found in document.</xsl:text>
          </xsl:message>
        </xsl:if>
        <xsl:value-of select="local-name(key('id',$rootid)[1])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="local-name(/*[1])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="test4para">
    <xsl:choose>
      <!-- Test, if the second element is a section. In that case,
                 insert a para to make it a valid Novdoc source
                 depending on the $createvalid parameter
            -->
      <xsl:when test="*[2][self::sect1 or self::sect2 or self::sect3 or self::sect4 or self::section]">
        <xsl:apply-templates select="title"/>
        <xsl:choose>
          <xsl:when test="$createvalid != 0">
            <para><remark role="fixme">Add a short description</remark></para>
          </xsl:when>
          <xsl:otherwise>
            <xsl:comment>FIXME: Add a short description</xsl:comment>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="node()[not(self::title)]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="process.menuchoice">
    <xsl:param name="nodelist"
               select="guibutton|guiicon|guilabel|guimenu|
                       guimenuitem|guisubmenu|interface"/><!-- not(shortcut) -->
    <xsl:param name="count" select="1"/>

    <xsl:choose>
      <xsl:when test="$count>count($nodelist)"></xsl:when>
      <xsl:when test="$count=1">
        <xsl:apply-templates select="$nodelist[$count=position()]"/>
        <xsl:call-template name="process.menuchoice">
          <xsl:with-param name="nodelist" select="$nodelist"/>
          <xsl:with-param name="count" select="$count+1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="node" select="$nodelist[$count=position()]"/>
        <xsl:choose>
          <xsl:when test="local-name($node)='guimenuitem'
            or local-name($node)='guisubmenu'">
            <xsl:value-of select="$menuchoice.menu.separator"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$menuchoice.separator"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="$node"/>
        <xsl:call-template name="process.menuchoice">
          <xsl:with-param name="nodelist" select="$nodelist"/>
          <xsl:with-param name="count" select="$count+1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- ################################################################## -->
  <!-- Templates                                                          -->

  <xsl:template match="book/title|book/titleabbrev"/><!-- Don't copy -->
  <xsl:template match="bookinfo">
    <bookinfo>
      <xsl:copy-of select="(title|../title)[1]"/>
      <xsl:apply-templates select="productname"/>
      <xsl:apply-templates select="productnumber"/>
      <xsl:apply-templates select="date"/>
      <xsl:apply-templates select="legalnotice"/>
      <xsl:apply-templates select="abstract"/>
    </bookinfo>
  </xsl:template>

  <!-- ################################################################## -->
  <!-- Templates for Division Elements                                    -->
  <xsl:template match="section">
    <xsl:variable name="depth" select="count(ancestor::section)+1"/>

    <xsl:choose>
      <xsl:when test="$depth &lt; 5">
        <xsl:element name="sect{$depth}">
          <xsl:apply-templates select="@*"/>
          <xsl:call-template name="test4para"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <!--<xsl:message>***<xsl:value-of select="concat(name(), ' #' , @id)"/>: <xsl:value-of
        select="$depth"/></xsl:message>-->
        <xsl:text>&#10;</xsl:text>
        <xsl:comment>sect5</xsl:comment>
        <bridgehead><!--  id="{@id}" -->
          <xsl:copy-of select="@id"/>
          <xsl:apply-templates select="title"/>
        </bridgehead>
        <xsl:apply-templates select="node()[not(self::title)]"/>
        <xsl:comment>/sect5</xsl:comment>
        <xsl:text>&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="section/section/section/section/section/title|sect5/title">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="sect1|sect2|sect3|sect4">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="test4para"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="sect5">
    <xsl:message>bridgehead: <xsl:value-of select="name()"/></xsl:message>
    <bridgehead>
       <xsl:copy-of select="@id"/>
       <xsl:apply-templates select="title"/>
    </bridgehead>
    <xsl:apply-templates select="node()[not(self::title)]"/>
  </xsl:template>

  <!-- ################################################################## -->
  <!-- Templates for Inline Elements                                      -->

  <xsl:template match="application|abbrev|firstterm|para/glossterm">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="command/command">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="citetitle/*">
    <xsl:call-template name="info">
      <xsl:with-param name="text">Removed citetitle/<xsl:value-of select="local-name()"/> </xsl:with-param>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="guilabel|guibutton|guimenuitem|guiicon|guisubmenu">
    <guimenu>
      <xsl:apply-templates/>
    </guimenu>
  </xsl:template>

  <xsl:template match="guilabel/replaceable|guimenu/replaceable">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="constant|errorcode|classname|code|computeroutput|methodname|
                       prompt[not(parent::screen)]|sgmltag|returnvalue|uri|userinput">
    <literal>
      <xsl:apply-templates/>
    </literal>
  </xsl:template>

  <xsl:template match="errortext">
    <emphasis>
      <xsl:apply-templates/>
    </emphasis>
  </xsl:template>

  <xsl:template match="literal[ulink]">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="literal/ulink[normalize-space(.) != '']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <literal>
        <xsl:apply-templates/>
      </literal>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="entry[not(*)][normalize-space(text() != '')]">
    <!-- entry[&dbinline;]|  -->
    <xsl:call-template name="info">
      <xsl:with-param name="text">Added additional para</xsl:with-param>
    </xsl:call-template>
    <entry>
      <para>
        <xsl:apply-templates/>
      </para>
    </entry>
  </xsl:template>

  <xsl:template match="package">
    <systemitem class="resource">
      <xsl:apply-templates/>
    </systemitem>
  </xsl:template>

  <xsl:template match="parameter">
    <option>
      <xsl:apply-templates/>
    </option>
  </xsl:template>

  <xsl:template match="systemitem[@class='protocol']">
    <systemitem>
      <xsl:apply-templates/>
    </systemitem>
  </xsl:template>


  <!-- ################################################################## -->
  <!-- Templates for Block Elements                                       -->

  <xsl:template match="mediaobject[textobject]">
    <xsl:call-template name="info">
      <xsl:with-param name="text">Changed order of mediaobject/textobject</xsl:with-param>
    </xsl:call-template>
    <mediaobject>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="textobject"/>
      <xsl:apply-templates select="*[not(self::textobject)]"/>
    </mediaobject>
  </xsl:template>

  <xsl:template match="textobject[not(@role)]">
    <xsl:call-template name="info">
      <xsl:with-param name="text">Added missing textobject/@role attribute</xsl:with-param>
    </xsl:call-template>
    <textobject>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="role">description</xsl:attribute>
    </textobject>
  </xsl:template>

  <xsl:template match="mediaobject/textobject[screen]">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="literallayout">
    <screen>
      <xsl:apply-templates/>
    </screen>
  </xsl:template>

  <xsl:template match="simplelist[@type='vert']">
    <itemizedlist>
      <xsl:apply-templates/>
    </itemizedlist>
  </xsl:template>

  <xsl:template match="itemizedlist[para or note]">
    <xsl:apply-templates select="itemizedlist/para | itemizedlist/note"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()[not(self::para or self::note)]"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="listitem/procedure">
    <xsl:call-template name="info">
      <xsl:with-param name="text">
        <xsl:text>Converted listitem/procedure -> listitem/itemizedlist</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <itemizedlist>
      <xsl:apply-templates/>
    </itemizedlist>
  </xsl:template>
  <xsl:template match="listitem/procedure/step">
    <xsl:call-template name="info">
      <xsl:with-param name="text">
        <xsl:text>Converted listitem/procedure/step -> listitem/itemizedlist/listitem</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <listitem>
      <xsl:apply-templates/>
    </listitem>
  </xsl:template>

  <xsl:template match="note/procedure">
    <orderedlist>
      <xsl:apply-templates/>
    </orderedlist>
  </xsl:template>

  <xsl:template match="note/procedure/step">
    <listitem>
      <xsl:apply-templates/>
    </listitem>
  </xsl:template>

  <xsl:template match="note/formalpara">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="note[figure]|caution[figure]|warning[figure]|important[figure]">
    <xsl:comment> Removed <xsl:value-of select="name()"/> start</xsl:comment>
    <xsl:choose>
      <xsl:when test="@id">
        <xsl:call-template name="warn">
          <xsl:with-param name="text">
            <xsl:text>Admonition with id='</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text>' contains figure.&#10;</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="warn">
          <xsl:with-param name="text">
            <xsl:text>Removed admonition (</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>) and figure, but preserved content</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="*[not(self::title)]"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:comment> Removed <xsl:value-of select="name()"/> end</xsl:comment>
  </xsl:template>

  <xsl:template match="step/title">
    <para><emphasis role="bold">
      <xsl:apply-templates/>
    </emphasis></para>
  </xsl:template>

  <xsl:template match="stepalternatives|stepalternatives/step/substeps">
    <itemizedlist>
      <xsl:apply-templates/>
    </itemizedlist>
  </xsl:template>

  <xsl:template match="stepalternatives/step|stepalternatives/step/substeps/step">
    <listitem>
      <xsl:apply-templates/>
    </listitem>
  </xsl:template>

  <xsl:template match="title/menuchoice">
      <xsl:call-template name="process.menuchoice"/>
  </xsl:template>

  <xsl:template match="screen/@remap">
    <xsl:attribute name="remap">
      <xsl:value-of select="."/>
    <xsl:if test="../@language">
      <xsl:value-of select="concat('-', ../@language)"/>
    </xsl:if>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="entry/variablelist">
    <itemizedlist>
      <xsl:apply-templates/>
    </itemizedlist>
  </xsl:template>

  <xsl:template match="entry/variablelist/varlistentry">
    <listitem>
      <xsl:apply-templates select="term"/>
      <xsl:apply-templates select="node()[not(self::term)]"/>
    </listitem>
  </xsl:template>

  <xsl:template match="entry/variablelist/varlistentry/term">
    <para>
      <xsl:apply-templates/>
    </para>
  </xsl:template>

  <xsl:template match="entry/variablelist/varlistentry/listitem">
    <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>
