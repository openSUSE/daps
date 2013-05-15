<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  
  Need DocBook stylesheet version >= 1.77.0
  
  Run it as follows:

  $ xsltproc -xinclude chunk.xsl YOUR_XML_FILE.xml

-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY www "../../xhtml">
]>
<xsl:stylesheet version="1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:h="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="exsl h">
  
  <xsl:import href="&www;/chunk.xsl"/>
  <!--<xsl:import href="&www;/chunk-common.xsl"/>
  <xsl:include href="&www;/manifest.xsl"/>
  <xsl:include href="&www;/chunk-code.xsl"/>-->

  <xsl:include href="param.xsl"/>
  
  <xsl:template name="html.head">
    <xsl:param name="prev" select="/foo"/>
    <xsl:param name="next" select="/foo"/>
    <xsl:variable name="this" select="."/>
    <xsl:variable name="home" select="/*[1]"/>
    <xsl:variable name="up" select="parent::*"/>
    <!-- 
      The last() in the predicate ensure you will get always the article
      first, and not the book
    -->
    <xsl:variable name="next.book" 
      select="($next/ancestor-or-self::article |
               $next/ancestor-or-self::book)[last()]"/>
    <xsl:variable name="prev.book"
      select="($prev/ancestor-or-self::article |
               $prev/ancestor-or-self::book)[last()]"/>
    <xsl:variable name="this.book" 
      select="(ancestor-or-self::article|ancestor-or-self::book)[last()]"/>
    
    <xsl:variable name="up.book"
     select="($up/ancestor-or-self::article|$up/ancestor-or-self::book)[last()]"/>
    
    <xsl:variable name="isnext"  select="generate-id($this.book) = generate-id($next.book)"/>
    <xsl:variable name="isprev"  select="generate-id($this.book) = generate-id($prev.book)"/>
    <xsl:variable name="isup"    select="generate-id($this.book) = generate-id($up.book)"/>

    <!--<xsl:message>html.head: <xsl:value-of
      select="local-name()"/> "<xsl:apply-templates select="$this"
        mode="title.markup"/>"
      this.book: <xsl:value-of select="local-name($this.book)"/> "<xsl:apply-templates select="$this.book" mode="title.markup"/>"
      next.book: <xsl:value-of select="local-name($next.book)"/> "<xsl:apply-templates select="$next.book" mode="title.markup"/>"
      prev.book: <xsl:value-of select="local-name($prev.book)"/> "<xsl:apply-templates select="$prev.book" mode="title.markup"/>"
      up.book: <xsl:value-of select="local-name($up.book)"/> "<xsl:apply-templates select="$up.book" mode="title.markup"/>"
      
      isnext: <xsl:value-of select="concat($isnext, ' ', local-name($next))"/>
      isprev: <xsl:value-of select="concat($isprev, ' ', local-name($prev))"/>
      up: <xsl:value-of select="local-name($up)"/>  "<xsl:apply-templates select="$up" mode="title.markup"/>
      isup:   <xsl:value-of select="$isup"/>
    </xsl:message>-->
    <head>
      <xsl:call-template name="system.head.content"/>
      <xsl:call-template name="head.content"/>

      <!-- For Drupal -->
      <link rel="self">
        <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$this"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="title">
          <!--<xsl:apply-templates select="$this" 
            mode="title.markup"/>-->
          <xsl:apply-templates select="$this" mode="object.title.markup"/>
        </xsl:attribute>
      </link>
      <xsl:if test="$home">
        <link rel="home">
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="$home"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="title">
            <!-- Change: Take into account productname and productnumber -->
            <xsl:choose>
              <xsl:when test="/book/bookinfo/productname and not(/book/title)">
                <xsl:value-of select="normalize-space(/book/bookinfo/productname)"/>
                <xsl:if test="/book/bookinfo/productnumber">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="normalize-space(/book/bookinfo/productnumber)"/>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="$home" mode="object.title.markup.textonly"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </link>
      </xsl:if>
      <xsl:if test="$up and $isup">
        <link rel="up">
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="$up"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:apply-templates select="$up" mode="object.title.markup.textonly"/>
          </xsl:attribute>
        </link>
      </xsl:if>

      <xsl:if test="$prev and $isprev">
        <link rel="previous">
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="$prev"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:apply-templates select="$prev" mode="object.title.markup.textonly"/>
          </xsl:attribute>
        </link>
      </xsl:if>

      <xsl:if test="$next and $isnext">
        <link rel="next">
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="$next"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:apply-templates select="$next" mode="object.title.markup.textonly"/>
          </xsl:attribute>
        </link>
      </xsl:if>
    </head>
</xsl:template>
 
  <!-- Drupal don't need any titlepage structures -->
  <xsl:template name="article.titlepage"/>
  <xsl:template name="book.titlepage"/>
  <xsl:template name="appendix.titlepage"/>
  <xsl:template name="chapter.titlepage"/>
  <xsl:template name="preface.titlepage"/>
  
  <xsl:template name="sect1.titlepage">
    <xsl:apply-templates mode="sect1.titlepage.recto.auto.mode"
      select="(sect1info/title|info/title|title)[1]"/>
    <xsl:apply-templates mode="sect1.titlepage.recto.auto.mode"
      select="(sect1info/subtitle|info/subtitle|subtitle)[1]"/>
  </xsl:template>
  <xsl:template name="sect2.titlepage">
    <xsl:apply-templates mode="sect2.titlepage.recto.auto.mode"
      select="(sect2info/title|info/title|title)[1]"/>
    <xsl:apply-templates mode="sect2.titlepage.recto.auto.mode"
      select="(sect2info/subtitle|info/subtitle|subtitle)[1]"/>
  </xsl:template>
  <xsl:template name="sect3.titlepage">
    <xsl:apply-templates mode="sect3.titlepage.recto.auto.mode"
      select="(sect3info/title|info/title|title)[1]"/>
    <xsl:apply-templates mode="sect3.titlepage.recto.auto.mode"
      select="(sect3info/subtitle|info/subtitle|subtitle)[1]"/>
  </xsl:template>
  
  
  <xsl:template name="chunk-element-content">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="nav.context"/>
    <xsl:param name="content">
      <xsl:apply-imports/>
    </xsl:param>
    
    <xsl:variable name="full-contents">
      <xsl:call-template name="chunk-element-content-html">
        <xsl:with-param name="content" select="$content"/>
        <xsl:with-param name="next" select="$next"/>
        <xsl:with-param name="prev" select="$prev"/>
        <xsl:with-param name="nav.context" select="$nav.context"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="html" select="exsl:node-set($full-contents)/*"/>
    
    <xsl:apply-templates select="$html" mode="drupal"/>
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="drupal">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="drupal"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="h:div[@id='_outer-wrap']" mode="drupal">
    <xsl:apply-templates select="h:div[@id='_content']" mode="drupal"/>
  </xsl:template>
  
  <xsl:template match="h:div[@id='_white-bg']" mode="drupal"/>
  <xsl:template match="h:div[@id='_toolbar-wrap']" mode="drupal"/>
  <xsl:template match="h:div[@id='_footer-wrap']" mode="drupal"/>
  <xsl:template match="h:div[@id='_fixed-header-wrap']" mode="drupal"/>
  <xsl:template match="h:div[@class='page-bottom']" mode="drupal"/>
  <xsl:template match="h:div[@class='line']" mode="drupal"/>
  <xsl:template match="h:link[@rel='self']" mode="drupal"/>
  <xsl:template match="h:div[@class='titlepage']" mode="drupal"/>
  <xsl:template match="h:a[@class='permalink']" mode="drupal"/>
  
  <xsl:template match="h:div[@class='sect4' or @class='sect5']/h:div[@class='titlepage']" mode="drupal">
    <xsl:apply-templates select=".//h:h5|.//h:h6" mode="drupal"/>
  </xsl:template>
  
  <xsl:template match="h:table/@border" mode="drupal"/>
    
  
  <!-- ========================================================= -->
  <xsl:template name="inline.sansseq">
  <xsl:param name="content">
    <xsl:call-template name="anchor"/>
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>
    <span class="{local-name(.)}">
      <xsl:call-template name="generate.html.title"/>
      <xsl:if test="@dir">
        <xsl:attribute name="dir">
          <xsl:value-of select="@dir"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="$content"/>
      <xsl:call-template name="apply-annotations"/>
    </span>
  </xsl:template>
  
  <xsl:template match="keycap" priority="10">
  <!-- See also Ticket#84 -->
  <!--  <xsl:message>keycap: <xsl:value-of select="concat(@function, '-',
      normalize-space())"/></xsl:message>-->
   <xsl:choose>
       <xsl:when test="@function">
         <xsl:call-template name="inline.sansseq">
            <xsl:with-param name="content">
               <xsl:call-template name="gentext.template">
                  <xsl:with-param name="context" select="'msgset'"/>
                  <xsl:with-param name="name" select="@function"/>
               </xsl:call-template>
            </xsl:with-param>
         </xsl:call-template>
       </xsl:when>
       <xsl:otherwise>
         <xsl:call-template name="inline.sansseq"/>
       </xsl:otherwise>
   </xsl:choose>
  </xsl:template>
  
  
  <xsl:template match="*" mode="recursive-chunk-filename">
    <xsl:param name="recursive" select="false()"/>

    <!-- returns the filename of a chunk -->
    <xsl:variable name="ischunk">
      <xsl:call-template name="chunk"/>
    </xsl:variable>

    <xsl:variable name="dbhtml-filename">
      <xsl:call-template name="pi.dbhtml_filename"/>
    </xsl:variable>

    <xsl:variable name="filename">
      <xsl:choose>
        <xsl:when test="$dbhtml-filename != ''">
          <xsl:value-of select="$dbhtml-filename"/>
        </xsl:when>
        <!-- if this is the root element, use the root.filename -->
        <xsl:when test="not(parent::*) and $root.filename != ''">
          <xsl:value-of select="$root.filename"/>
          <xsl:value-of select="$html.ext"/>
        </xsl:when>
        <!-- Special case -->
        <xsl:when
          test="self::legalnotice and not($generate.legalnotice.link = 0)">
          <xsl:choose>
            <xsl:when
              test="(@id or @xml:id) and not($use.id.as.filename = 0)">
              <!-- * if this legalnotice has an ID, then go ahead and use -->
              <!-- * just the value of that ID as the basename for the file -->
              <!-- * (that is, without prepending an "ln-" too it) -->
              <xsl:value-of select="(@id|@xml:id)[1]"/>
              <xsl:value-of select="$html.ext"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- * otherwise, if this legalnotice does not have an ID, -->
              <!-- * then we generate an ID... -->
              <xsl:variable name="id">
                <xsl:call-template name="object.id"/>
              </xsl:variable>
              <!-- * ...and then we take that generated ID, prepend an -->
              <!-- * "ln-" to it, and use that as the basename for the file -->
              <xsl:value-of select="concat('ln-',$id,$html.ext)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <!-- if there's no dbhtml filename, and if we're to use IDs as -->
        <!-- filenames, then use the ID to generate the filename. -->
        <xsl:when test="(@id or @xml:id) and $use.id.as.filename != 0">
          <xsl:value-of select="(@id|@xml:id)[1]"/>
          <xsl:value-of select="$html.ext"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>


    <!--<xsl:if test="$ischunk != 0">
      <xsl:message>Name: <xsl:value-of 
      select="concat(local-name(.), ':', $filename, '  ', @id)"/></xsl:message>
     </xsl:if>-->
    
    <xsl:choose>
      <xsl:when test="$ischunk='0'">
        <!-- if called on something that isn't a chunk, walk up... -->
        <xsl:choose>
          <xsl:when test="count(parent::*)&gt;0">
            <xsl:apply-templates mode="recursive-chunk-filename"
              select="parent::*">
              <xsl:with-param name="recursive" select="$recursive"/>
            </xsl:apply-templates>
          </xsl:when>
          <!-- unless there is no up, in which case return "" -->
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:when>

      <!-- Use $root.filename, if we have set $rootid to a book, for
           example
      -->
      <xsl:when test="not($recursive) and $rootid != '' and
                      generate-id(key('id', $rootid)) = generate-id(.)">
        <xsl:value-of select="$root.filename"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="not($recursive) and $filename != ''">
        <!-- if this chunk has an explicit name, use it -->
        <xsl:value-of select="$filename"/>
      </xsl:when>

      <xsl:when test="self::set">
        <xsl:value-of select="$root.filename"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="self::book">
        <xsl:text>bk</xsl:text>
        <xsl:number level="any" format="01"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="self::article">
        <xsl:if test="/set">
          <!-- in a set, make sure we inherit the right book info... -->
          <xsl:apply-templates mode="recursive-chunk-filename"
            select="parent::*">
            <xsl:with-param name="recursive" select="true()"/>
          </xsl:apply-templates>
        </xsl:if>

        <xsl:text>ar</xsl:text>
        <xsl:number level="any" format="01" from="book"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="self::preface">
        <xsl:if test="/set">
          <!-- in a set, make sure we inherit the right book info... -->
          <xsl:apply-templates mode="recursive-chunk-filename"
            select="parent::*">
            <xsl:with-param name="recursive" select="true()"/>
          </xsl:apply-templates>
        </xsl:if>

        <xsl:text>pr</xsl:text>
        <xsl:number level="any" format="01" from="book"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="self::chapter">
        <xsl:if test="/set">
          <!-- in a set, make sure we inherit the right book info... -->
          <xsl:apply-templates mode="recursive-chunk-filename"
            select="parent::*">
            <xsl:with-param name="recursive" select="true()"/>
          </xsl:apply-templates>
        </xsl:if>

        <xsl:text>ch</xsl:text>
        <xsl:number level="any" format="01" from="book"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="self::appendix">
        <xsl:if test="/set">
          <!-- in a set, make sure we inherit the right book info... -->
          <xsl:apply-templates mode="recursive-chunk-filename"
            select="parent::*">
            <xsl:with-param name="recursive" select="true()"/>
          </xsl:apply-templates>
        </xsl:if>

        <xsl:text>ap</xsl:text>
        <xsl:number level="any" format="a" from="book"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="self::part">
        <xsl:choose>
          <xsl:when test="/set">
            <!-- in a set, make sure we inherit the right book info... -->
            <xsl:apply-templates mode="recursive-chunk-filename"
              select="parent::*">
              <xsl:with-param name="recursive" select="true()"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>

        <xsl:text>pt</xsl:text>
        <xsl:number level="any" format="01" from="book"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="self::reference">
        <xsl:choose>
          <xsl:when test="/set">
            <!-- in a set, make sure we inherit the right book info... -->
            <xsl:apply-templates mode="recursive-chunk-filename"
              select="parent::*">
              <xsl:with-param name="recursive" select="true()"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>

        <xsl:text>rn</xsl:text>
        <xsl:number level="any" format="01" from="book"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="self::refentry">
        <xsl:choose>
          <xsl:when test="parent::reference">
            <xsl:apply-templates mode="recursive-chunk-filename"
              select="parent::*">
              <xsl:with-param name="recursive" select="true()"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="/set">
              <!-- in a set, make sure we inherit the right book info... -->
              <xsl:apply-templates mode="recursive-chunk-filename"
                select="parent::*">
                <xsl:with-param name="recursive" select="true()"/>
              </xsl:apply-templates>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:text>re</xsl:text>
        <xsl:number level="any" format="01" from="book"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="self::colophon">
        <xsl:choose>
          <xsl:when test="/set">
            <!-- in a set, make sure we inherit the right book info... -->
            <xsl:apply-templates mode="recursive-chunk-filename"
              select="parent::*">
              <xsl:with-param name="recursive" select="true()"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>

        <xsl:text>co</xsl:text>
        <xsl:number level="any" format="01" from="book"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when
        test="self::sect1                     or self::sect2                     or self::sect3                     or self::sect4                     or self::sect5                     or self::section">
        <xsl:apply-templates mode="recursive-chunk-filename"
          select="parent::*">
          <xsl:with-param name="recursive" select="true()"/>
        </xsl:apply-templates>
        <xsl:text>s</xsl:text>
        <xsl:number format="01"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="self::bibliography">
        <xsl:choose>
          <xsl:when test="/set">
            <!-- in a set, make sure we inherit the right book info... -->
            <xsl:apply-templates mode="recursive-chunk-filename"
              select="parent::*">
              <xsl:with-param name="recursive" select="true()"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>

        <xsl:text>bi</xsl:text>
        <xsl:number level="any" format="01" from="book"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="self::glossary">
        <xsl:choose>
          <xsl:when test="/set">
            <!-- in a set, make sure we inherit the right book info... -->
            <xsl:apply-templates mode="recursive-chunk-filename"
              select="parent::*">
              <xsl:with-param name="recursive" select="true()"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>

        <xsl:text>go</xsl:text>
        <xsl:number level="any" format="01" from="book"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="self::index">
        <xsl:choose>
          <xsl:when test="/set">
            <!-- in a set, make sure we inherit the right book info... -->
            <xsl:apply-templates mode="recursive-chunk-filename"
              select="parent::*">
              <xsl:with-param name="recursive" select="true()"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>

        <xsl:text>ix</xsl:text>
        <xsl:number level="any" format="01" from="book"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="self::setindex">
        <xsl:text>si</xsl:text>
        <xsl:number level="any" format="01" from="set"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:when test="self::topic">
        <xsl:choose>
          <xsl:when test="/set">
            <!-- in a set, make sure we inherit the right book info... -->
            <xsl:apply-templates mode="recursive-chunk-filename"
              select="parent::*">
              <xsl:with-param name="recursive" select="true()"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise> </xsl:otherwise>
        </xsl:choose>

        <xsl:text>to</xsl:text>
        <xsl:number level="any" format="01" from="book"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:when>

      <xsl:otherwise>
        <xsl:text>chunk-filename-error-</xsl:text>
        <xsl:value-of select="name(.)"/>
        <xsl:number level="any" format="01" from="set"/>
        <xsl:if test="not($recursive)">
          <xsl:value-of select="$html.ext"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>