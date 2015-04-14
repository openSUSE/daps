<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Pretty prints DocBook or Novdoc documents
     
   Parameters:
     * indendation (string)
       String containing spaces
     * indent.comments (boolean)
       Should comments be indented? 0=no, 1=yes
     * indent.pis (boolean)
       Should processing instructions be indented? 0=no, 1=yes

   Input:
     DocBook/Novdoc document
     
   Output:
     Indented DocBook document
     
   Bugs:
     Paragraph with elements is not correctly indented.
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH
   
-->
<!DOCTYPE xsl:stylesheet 
[
  <!ENTITY divs      "appendix|acknowledgements|article|
                      book|bridgehead|chapter|colophon|
                      dedication|glossary|index|lot|preface|reference|
                      refsect1|refsect2|refsect3|refsection|
                      sect1|sect2|sect3|sect4|sect5|section|
                      set|simplesect|toc">
  <!ENTITY parentdivs  "parent::appendix|parent::acknowledgements|parent::article|
                      parent::book|parent::bridgehead|parent::chapter|
                      parent::colophon|parent::dedication|parent::glossary|
                      parent::index|parent::lot|parent::preface|parent::reference|
                      parent::refsect1|parent::refsect2|parent::refsect3|
                      parent::refsection|parent::sect1|parent::sect2|parent::sect3|
                      parent::sect4|parent::sect5|parent::section|parent::set|
                      parent::simplesect|parent::toc">
  <!ENTITY parentinfodivs
                     "parent::appendixinfo|parent::articleinfo|
                      parent::bookinfo|parent::chapterinfo|parent::glossaryinfo|
                      parent::prefaceinfo|parent::referenceinfo|
                      parent::refsect1info|parent::refsect2info|parent::refsect3info|
                      parent::refsectioninfo|
                      parent::sect1info|parent::sect2info|parent::sect3info|
                      parent::sect4info|parent::sect5info|parent::sectioninfo|
                      parent::setinfo">
]>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- 
       doctype-public="-//OASIS//DTD DocBook XML V4.5//EN"
       doctype-system="http://www.docbook.org/xml/4.5/docbookx.dtd"
  -->
  <xsl:output method="xml"/>
  
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="address screen programlisting"/>
    
  <!-- ================================================================ -->
  <!-- Parameters -->
  <xsl:param name="indendation" select="'   '"/>
  <xsl:param name="indent.comments" select="1"/>
  <xsl:param name="indent.pis" select="1"/>

  <!-- ================================================================ -->
  <xsl:template match="@*">    
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Don't copy the default values of these attributes: -->
  <xsl:template match="@significance[. = 'normal']"/>
  <xsl:template match="@moreinfo[. = 'none']"/>
  <xsl:template match="@format[. = 'linespecific']"/>
  <xsl:template match="@performance[. = 'required']"/>
  <xsl:template match="@class[. = 'trade']"/>
  
  <!-- ================================================================ -->
  <xsl:template name="block.with.lb">
    <xsl:param name="indent" select="'&#xA;'"/>
    <xsl:param name="lb.before.end" select="1"/>
    <xsl:param name="lb.before.start" select="1"/>
    
    <xsl:if test="$lb.before.start != 0">
      <xsl:value-of select="$indent"/>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="indent" select="concat($indent, $indendation)"/>
      </xsl:apply-templates>
      <xsl:if test="$lb.before.end != 0">
        <xsl:value-of select="$indent"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================ -->
  <!-- Standard Rules -->
  <xsl:template match="comment()|processing-instruction()">
    <xsl:param name="indent" select="'&#xA;'"/>
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="comment()[&parentdivs;]|/comment()">
    <xsl:param name="indent" select="'&#xA;'"/>
    <xsl:if test="$indent.comments != 0">
      <xsl:value-of select="$indent"/>
    </xsl:if>
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="processing-instruction()[&parentdivs;]|
                       /processing-instruction()">
    <xsl:param name="indent" select="'&#xA;'"/>
    <xsl:if test="$indent.pis != 0">
      <xsl:value-of select="$indent"/>
    </xsl:if>
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="*">
    <xsl:param name="indent" select="'&#xA;'"/>

    <xsl:message>WARNING: Unknown element "<xsl:value-of
      select="local-name()"/>" in parent "<xsl:value-of
        select="local-name(..)"/>". Formatting as block.
    </xsl:message>
    <xsl:call-template name="block.with.lb">
      <xsl:with-param name="indent" select="$indent"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Copy empty elements and leave it as they are -->
  <xsl:template match="*[. = '' and not(processing-instruction())]">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  
  <!-- ================================================================ -->
  <!-- Inline Elements -->
  <xsl:template match="accel|acronym|action|application|
                       biblioref|citation|
                       citerefentry|city|classname|
                       co|code|collabname|command|constant|coref|country|database|
                       email|emphasis|envar|errorcode|errorname|errortext|
                       errortype|exceptionname|faxfilename|filename|firstname|footnote|
                       footnoteref|foreignphrase|funcdef|funcparams|
                       funcprototype|function|group|guibutton|guiicon|
                       guilabel|guimenu|guimenuitem|guisubmenu|hardware|
                       holder|honorific|inlinequation|inlinegraphic|
                       indexterm|
                       inlinemediaobject|interface|interfacename|
                       invpartnumber|itermset|jobtitle|keycap|
                       keycode|keycombo|keysym|label|lineage|lineannotation|
                       link|literal|manvolum|markup|mathphrase|medialabel|
                       menuchoice|methodname|methodparam|modespec|modifier|mousebutton|
                       nonterminal|olink|ooclass|ooexception|oointerface|
                       option|optional|orgdiv|otheraddr|
                       othername|package|pagenums|paramdef|parameter|phone|
                       phrase|pob|postcode|primary|primaryie|
                       prompt|property|quote|remark|replaceable|returnvalue|
                       revnumber|revremark|rhs|seriesvolums|sgmltag|shortcut|
                       state|street|structfield|structname|subscript|surname|
                       superscript|symbol|systemitem|tag|termdef|token|
                       trademark|type|ulink|uri|userinput|varargs|varname|
                       void|wordasword|xref|year">
    <xsl:param name="indent" select="'&#xA;'"/>
    
    <xsl:call-template name="block.with.lb">
      <xsl:with-param name="lb.before.start" select="0"/>
      <xsl:with-param name="lb.before.end" select="0"/>
      <xsl:with-param name="indent" select="$indent"/>
    </xsl:call-template>
  </xsl:template>
  
    
  <!-- ================================================================ -->
  <!-- "Block" Elements in *info need special treatment -->
  <!--<xsl:template match="author|authorblurb|editor|
                       keywordset|othercredit">
    <xsl:param name="indent" select="'&#xA;'"/>
    
    <xsl:choose>
      <xsl:when test="&parentinfodivs;">
        <xsl:call-template name="block.with.lb">
          <xsl:with-param name="lb.before.start" select="1"/>
          <xsl:with-param name="lb.before.end" select="1"/>
          <xsl:with-param name="indent" select="$indent"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="block.with.lb">
          <xsl:with-param name="indent" select="$indent"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>-->
  
  <!-- "Inline" Elements in *info need special treatment -->
  <xsl:template match="abbrev|artpagenums|
                       authorinitials|affiliation|
                       bibliocoverage|biblioid|bibliomisc|bibliocoverage|
                       bibliomisc|bibliorelation|bibliosource|biblioset|
                       citebiblioid|citetitle|
                       collab|confgroup|contractnum|contractsponsor|contrib|
                       copyright|corpauthor|corpname|corpcredit|
                       edition|
                       invpartnumber|isbn|issn|issuenum|orgname|
                       printhistory|productname|productnumber|
                       pubdate|personname|printhistory|publisher|publishername|
                       pubsnumber|releaseinfo|seriesvolnums|
                       subjectset">
    <xsl:param name="indent" select="'&#xA;'"/>
    
    <xsl:choose>
      <xsl:when test="&parentinfodivs;">
        <xsl:call-template name="block.with.lb">
          <xsl:with-param name="lb.before.start" select="1"/>
          <xsl:with-param name="lb.before.end" select="0"/>
          <xsl:with-param name="indent" select="$indent"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="block.with.lb">
          <xsl:with-param name="indent" select="$indent"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="term">
    <xsl:param name="indent" select="'&#xA;'"/>
    
    <xsl:call-template name="block.with.lb">
      <xsl:with-param name="lb.before.start" select="1"/>
      <xsl:with-param name="lb.before.end" select="0"/>
      <xsl:with-param name="indent" select="$indent"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- ================================================================ -->
  <!-- Block Elements -->
  <xsl:template match="abstract|ackno|acknowledgements|annotation|
                       answer|appendix|appendixinfo|arc|area|areaset|areaspec|
                       article|articleinfo|audiodata|audioobject|beginpage|
                       bibliodiv|biblioentry|bibliography|bibliographyinfo|
                       bibliolist|bibliomixed|bibliomset|biblioset|blockinfo|
                       blockquote|book|bookinfo|bridgehead|callout|
                       calloutlist|caption|caution|chapter|chapterinfo|
                       classsynopsis|classsynopsisinfo|cmdsynopsis|col|
                       colgroup|colophon|constraint|contraintdef|
                       constructorsynopsis|cover|dedication|
                       destructorsynopsis|docinfo|entry|entrytbl|epigraph|
                       equation|example|extendedlink|figure|
                       formalpara|funcsynopsis|funcsynopsisinfo|
                       glossary|glossaryinfo|glossdef|glossdif|glossentry|
                       glosslist|glosssee|glossseealso|graphic|graphicco|
                       highlights|imagedata|imageobject|important|index|
                       indexdiv|indexentry|indexinfo|info|informalequation|
                       informalexample|informalfigure|informaltable|
                       itemizedlist|label|legalnotice|lhs|listitem|lot|
                       lotentry|mediaobject|mediaobjectco|methodsynopsis|
                       msgentry|msgmain|msgset|note|objectinfo|orderedlist|
                       part|partinfo|personblurb|person|preface|
                       prefaceinfo|printhistory|procedure|production|
                       productionrecap|productionset|
                       programlistingco|qandadiv|qandaentry|qandaset|
                       question|refentry|refentryinfo|refentrytitle|
                       reference|referenceinfo|refnamediv|refsect1|
                       refsect1info|refsect2|refsect2info|refsect3|
                       refsect3info|refsection|refsectioninfo|refsynopsisdiv|
                       refsynopsisdivinfo|revhistory|revision|row|
                       screenco|screeninfo|screenshot|sect1|sect1info|
                       sect2|sect2info|sect3|sect3info|sect4|sect4info|
                       sect5|sect5info|section|seglistitem|segmentedlist|
                       set|setindex|setindexinfo|setinfo|sidebar|
                       simplelist|simplemsgentry|simplesect|step|
                       stepalternatives|substeps|synopfragment|synopsis|table|
                       task|taskprerequisites|taskrelated|tasksummary|tbody|
                       td|textobject|tfoot|tgroup|th|thead|tip|toc|tocback|
                       tocchap|tocdiv|tocentry|tocfront|toclevel1|toclevel2|
                       toclevel3|toclevel4|toclevel5|tocpart|variablelist|
                       varlistentry|videobject|warning">
    <xsl:param name="indent" select="'&#xA;'"/>
    
    <xsl:call-template name="block.with.lb">
      <xsl:with-param name="indent" select="$indent"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ================================================================ -->
  <!-- Verbatim Elements -->
  <xsl:template match="address|literallayout|programlisting|screen">
    <xsl:param name="indent" select="'&#xA;'"/>
    
    <xsl:value-of select="$indent"/>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>


  <!-- ================================================================ -->
  <!-- Element with special treatment  -->
  <xsl:template match="authorgroup|
                       author[&parentdivs;]|
                       indexterm[&parentdivs;]|
                       indexterm[&parentinfodivs;]|
                       keywordset[&parentinfodivs;]|
                       personname[&parentinfodivs;]|
                       subjectset[&parentinfodivs;]|
                       remark[&parentdivs;]">
    <xsl:param name="indent" select="'&#xA;'"/>

    <xsl:call-template name="block.with.lb">
      <xsl:with-param name="indent" select="$indent"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="author[&parentinfodivs;]/* |
                       personname[&parentinfodivs;]/* |
                       date[parent::revision | &parentinfodivs;] |
                       indexterm[&parentdivs;]/* |
                       indexterm[&parentinfodivs;]/* |
                       keywordset[&parentinfodivs;]/keyword">
    <xsl:param name="indent" select="'&#xA;'"/>
    
    <xsl:call-template name="block.with.lb">
      <xsl:with-param name="indent" select="$indent"/>
      <xsl:with-param name="lb.before.end" select="0"/>
    </xsl:call-template>
  </xsl:template>
 
  <xsl:template match="authorgroup/author| 
                       authorgroup/editor|
                       authorgroup/othercredit">
    <xsl:param name="indent" select="'&#xA;'"/>
    <xsl:call-template name="block.with.lb">
      <xsl:with-param name="indent" select="$indent"/>
      <xsl:with-param name="lb.before.end" select="1"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="authorgroup/author/*| 
                       authorgroup/editor/*|
                       authorgroup/othercredit/*|
                       authorgroup/corpauthor|
                       authorgroup/corpcredit|
                       collab/*">
    <xsl:param name="indent" select="'&#xA;'"/>
    <xsl:call-template name="block.with.lb">
      <xsl:with-param name="indent" select="$indent"/>
      <xsl:with-param name="lb.before.end" select="0"/>
    </xsl:call-template>
  </xsl:template>
  
  
  <xsl:template match="title|subtitle|titleabbrev">
    <xsl:param name="indent" select="'&#xA;'"/>
    
    <xsl:call-template name="block.with.lb">
      <xsl:with-param name="lb.before.end" select="0"/>
      <xsl:with-param name="indent" select="$indent"/>
    </xsl:call-template>
  </xsl:template>
  
  
  <!-- ================================================================ -->
  <!-- Paragraphs
    
    Only for paragraphs with text only (but without any child
    elements)
  -->
  <xsl:template match="para[count(*)=0 and normalize-space() != '']|
                       simpara[count(*)=0 and normalize-space() != '']">
    <xsl:param name="indent" select="'&#xA;'"/>

    <xsl:value-of select="$indent"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="normalize-space()"/>
    </xsl:copy>
  </xsl:template>

  <!-- TODO: Add useful algorithm -->
  <xsl:template match="para[count(*)>0] | simpara[count(*)>0]">
    <xsl:param name="indent" select="'&#xA;'"/>
    
    <xsl:value-of select="$indent"/>
    <xsl:copy>
    <xsl:apply-templates select="@*|node()" mode="para">
      <xsl:with-param name="indent" select="$indent"/>
    </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  
  
  <xsl:template match="*" mode="para"> 
    <xsl:param name="indent" select="'&#xA;'"/>
    
    <xsl:message>WARNING: TODO <xsl:value-of
      select="concat(local-name(),
        ' in ', local-name(..) )"/>
    </xsl:message>
    <xsl:apply-templates mode="para"/>
  </xsl:template>
  
  
  <xsl:template match="author|othercredit" mode="para">
    <xsl:param name="indent" select="'&#xA;'"/>
    <xsl:call-template name="block.with.lb">
          <xsl:with-param name="lb.before.start" select="0"/>
          <xsl:with-param name="lb.before.end" select="1"/>
          <xsl:with-param name="indent" select="$indent"/>
        </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="author/*|othercredit/*|menuchoice/*" mode="para">
    <xsl:param name="indent" select="'&#xA;'"/>
    <xsl:call-template name="block.with.lb">
      <xsl:with-param name="lb.before.start" select="1"/>
      <xsl:with-param name="lb.before.end" select="0"/>
      <xsl:with-param name="indent" select="$indent"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="para/*" mode="para">
    <xsl:param name="indent" select="'&#xA;'"/>
    <xsl:call-template name="block.with.lb">
      <xsl:with-param name="lb.before.start" select="0"/>
      <xsl:with-param name="lb.before.end" select="0"/>
      <xsl:with-param name="indent" select="$indent"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="para/text()" mode="para">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <!-- WARNING: this is dangerous. Handle with care -->
  <xsl:template match="text()[normalize-space(.)='']"/>

</xsl:stylesheet>
