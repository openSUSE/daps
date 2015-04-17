<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  
   Purpose:
     Prepares the DocBook document for EPUB and inserts a path for all
     images at the beginning of each graphic name.
  
     Copies all elements, attributes, comments, processing instruction
     except for the @fileref attribute in imagedata element which is inside
     an imageobject with @role=$preferred.mediaobject.role.
  
     All imageobject elements which contains everything else than @role =
     $preferred.mediaobject.role will be discarded.
     
   Parameters:
     * rootid
       Applies stylesheet only to part of the document
       
     * rootid.debug (default: 0)
       Controls some log messages (0=no, 1=yes)
       
     * img.src.path
       Image paths to be added before @fileref in imagedata
       
     * preferred.mediaobject.role
       Prefers imageobjects which contains @role attribute with value
       from this parameter
     
     * use.role.for.mediaobject
       Should @role in imageobjects be used? 1=yes, 0=no
       
     * use.pi4date
       Should the PI <?dbtimestamp format="..."?> created instead of
       the current date? 0=no, 1=yes
     
   Original DocBook XSL Parameters:
     * stylesheet.result.type (default: 'xhtml')
     
     * use.svg (default: 1)
       Allow SVG in the result tree?
     
     * graphic.default.extension (default: '')
       Default extension for graphic filenames
   
   Dependencies:
       To common/rootid.xsl and common/copy.xsl, but not to the 
       original DocBook XSL stylesheets.
   
   Keys:
     * id (applys to: @id|@xml:id)
       Creates an index for all elements with IDs (derived from
       rootid.xsl)
       
   Input:
     DocBook 4/Novdoc document
     
   Output:
     DocBook 4/Novdoc document with corrected @fileref in imagedata
   
   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright (C) 2012-2015 SUSE Linux GmbH
-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY db "http://docbook.sourceforge.net/release/xsl/current">
]>
<xsl:stylesheet version="1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:date="http://exslt.org/dates-and-times"
  exclude-result-prefixes="db xlink date">

  <xsl:import href="../common/rootid.xsl"/>
  <xsl:import href="../common/copy.xsl"/>
  <xsl:import href="../common/xpath.location.xsl"/>
  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/lib/lib.xsl"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="screen"/>

<!-- Parameters                                                 -->
<!-- ALWAYS use a trailing slash! -->
<xsl:param name="img.src.path"/>
<xsl:param name="preferred.mediaobject.role">html</xsl:param>
<xsl:param name="use.role.for.mediaobject" select="1"/>
<xsl:param name="use.pi4date" select="1"/>
<xsl:param name="use.svg" select="1"/>
<xsl:param name="graphic.default.extension"/>
<xsl:param name="stylesheet.result.type" select="'xhtml'"/>


<!-- =============================================================== -->
<!-- Helper templates, copied from common/common.xsl and xhtml-1_1/graphics.xsl -->
<xsl:template name="is.graphic.format">
  <xsl:param name="format"/>
  <xsl:if test="$format = 'SVG' or 
                $format = 'PNG' or
                $format = 'JPG' or 
                $format = 'JPEG' or 
                $format = 'linespecific' or 
                $format = 'GIF' or 
                $format = 'GIF87a' or 
                $format = 'GIF89a' or 
                $format = 'BMP'">1</xsl:if>
</xsl:template>
 
<xsl:template name="is.graphic.extension">
  <xsl:param name="ext"/>
  <xsl:variable name="lcext" select="translate($ext, 
                              'ABCDEFGHIJKLMNOPQRSTUVWXYZ',                                        
                              'abcdefghijklmnopqrstuvwxyz')"/>
  <xsl:if test="$lcext = 'svg' or 
                $lcext = 'png' or 
                $lcext = 'jpeg' or 
                $lcext = 'jpg' or 
                $lcext = 'avi' or 
                $lcext = 'mpg' or 
                $lcext = 'mp4' or 
                $lcext = 'mpeg' or 
                $lcext = 'qt'  or 
                $lcext = 'gif' or 
                $lcext = 'acc' or 
                $lcext = 'mp1' or 
                $lcext = 'mp2' or 
                $lcext = 'mp3' or 
                $lcext = 'mp4' or 
                $lcext = 'm4v' or 
                $lcext = 'm4a' or 
                $lcext = 'wav' or 
                $lcext = 'ogv' or 
                $lcext = 'ogg' or 
                $lcext = 'webm' or 
                $lcext = 'bmp'">1</xsl:if>
</xsl:template>

<xsl:template name="filename-basename">
  <!-- We assume all filenames are really URIs and use "/" -->
  <xsl:param name="filename"></xsl:param>
  <xsl:param name="recurse" select="false()"/>

  <xsl:choose>
    <xsl:when test="substring-after($filename, '/') != ''">
      <xsl:call-template name="filename-basename">
        <xsl:with-param name="filename"
                        select="substring-after($filename, '/')"/>
        <xsl:with-param name="recurse" select="true()"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$filename"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
<xsl:template name="filename-extension">
  <xsl:param name="filename"></xsl:param>
  <xsl:param name="recurse" select="false()"/>

  <!-- Make sure we only look at the base name... -->
  <xsl:variable name="basefn">
    <xsl:choose>
      <xsl:when test="$recurse">
        <xsl:value-of select="$filename"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="filename-basename">
          <xsl:with-param name="filename" select="$filename"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="substring-after($basefn, '.') != ''">
      <xsl:call-template name="filename-extension">
        <xsl:with-param name="filename"
                        select="substring-after($basefn, '.')"/>
        <xsl:with-param name="recurse" select="true()"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$recurse">
      <xsl:value-of select="$basefn"/>
    </xsl:when>
    <xsl:otherwise></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="mediaobject.filename">
  <xsl:param name="object"></xsl:param>

  <xsl:variable name="data" select="$object/videodata
                                    |$object/imagedata
                                    |$object/audiodata
                                    |$object"/>

  <xsl:variable name="filename">
    <xsl:choose>
      <xsl:when test="$data[@fileref]">
        <xsl:apply-templates select="$data/@fileref"/>
      </xsl:when>
      <xsl:when test="$data[@entityref]">
        <xsl:value-of select="unparsed-entity-uri($data/@entityref)"/>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="real.ext">
    <xsl:call-template name="filename-extension">
      <xsl:with-param name="filename" select="$filename"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="ext">
    <xsl:choose>
      <xsl:when test="$real.ext != ''">
        <xsl:value-of select="$real.ext"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$graphic.default.extension"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="graphic.ext">
    <xsl:call-template name="is.graphic.extension">
      <xsl:with-param name="ext" select="$ext"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$real.ext = ''">
      <xsl:choose>
        <xsl:when test="$ext != ''">
          <xsl:value-of select="$filename"/>
          <xsl:text>.</xsl:text>
          <xsl:value-of select="$ext"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$filename"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="not($graphic.ext)">
      <xsl:choose>
        <xsl:when test="$graphic.default.extension != ''">
          <xsl:value-of select="$filename"/>
          <xsl:text>.</xsl:text>
          <xsl:value-of select="$graphic.default.extension"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$filename"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$filename"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="is.acceptable.mediaobject">
  <xsl:param name="object"></xsl:param>

  <xsl:variable name="filename">
    <xsl:call-template name="mediaobject.filename">
      <xsl:with-param name="object" select="$object"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="ext">
    <xsl:call-template name="filename-extension">
      <xsl:with-param name="filename" select="$filename"/>
    </xsl:call-template>
  </xsl:variable>

  <!-- there will only be one -->
  <xsl:variable name="data" select="$object/videodata
                                    |$object/imagedata
                                    |$object/audiodata"/>

  <xsl:variable name="format" select="$data/@format"/>

  <xsl:variable name="graphic.format">
    <xsl:if test="$format">
      <xsl:call-template name="is.graphic.format">
        <xsl:with-param name="format" select="$format"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="graphic.ext">
    <xsl:if test="$ext">
      <xsl:call-template name="is.graphic.extension">
        <xsl:with-param name="ext" select="$ext"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$use.svg = 0 and $format = 'SVG'">0</xsl:when>
    <xsl:when xmlns:svg="http://www.w3.org/2000/svg"
              test="$use.svg != 0 and $object/svg:*">1</xsl:when>
    <xsl:when test="$graphic.format = '1'">1</xsl:when>
    <xsl:when test="$graphic.ext = '1'">1</xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="select.mediaobject.index">
  <xsl:param name="olist"
             select="imageobject|imageobjectco
                     |videoobject|audioobject|textobject"/>
  <xsl:param name="count">1</xsl:param>

  <xsl:choose>
    <!-- Test for objects preferred by role -->
    <xsl:when test="$use.role.for.mediaobject != 0 
               and $preferred.mediaobject.role != ''
               and $olist[@role = $preferred.mediaobject.role]"> 
      
      <!-- Get the first hit's position index -->
      <xsl:for-each select="$olist">
        <xsl:if test="@role = $preferred.mediaobject.role and
             not(preceding-sibling::*[@role = $preferred.mediaobject.role])"> 
          <xsl:value-of select="position()"/> 
        </xsl:if>
      </xsl:for-each>
    </xsl:when>

    <xsl:when test="$use.role.for.mediaobject != 0 
               and $olist[@role = $stylesheet.result.type]">
      <!-- Get the first hit's position index -->
      <xsl:for-each select="$olist">
        <xsl:if test="@role = $stylesheet.result.type and 
              not(preceding-sibling::*[@role = $stylesheet.result.type])"> 
          <xsl:value-of select="position()"/> 
        </xsl:if>
      </xsl:for-each>
    </xsl:when>
    <!-- Accept 'html' for $stylesheet.result.type = 'xhtml' -->
    <xsl:when test="$use.role.for.mediaobject != 0 
               and $stylesheet.result.type = 'xhtml'
               and $olist[@role = 'html']">
      <!-- Get the first hit's position index -->
      <xsl:for-each select="$olist">
        <xsl:if test="@role = 'html' and 
              not(preceding-sibling::*[@role = 'html'])"> 
          <xsl:value-of select="position()"/> 
        </xsl:if>
      </xsl:for-each>
    </xsl:when>

    <!-- If no selection by role, and there is only one object, use it -->
    <xsl:when test="count($olist) = 1 and $count = 1">
      <xsl:value-of select="$count"/> 
    </xsl:when>

    <xsl:otherwise>
      <!-- Otherwise select first acceptable object -->
      <xsl:if test="$count &lt;= count($olist)">
        <xsl:variable name="object" select="$olist[position()=$count]"/>
    
        <xsl:variable name="useobject">
          <xsl:choose>
            <!-- select videoobject or audioobject before textobject -->
            <xsl:when test="local-name($object) = 'videoobject'">
              <xsl:text>1</xsl:text> 
            </xsl:when>
            <xsl:when test="local-name($object) = 'audioobject'">
              <xsl:text>1</xsl:text> 
            </xsl:when>
            <!-- skip textobject if also video, audio, or image out of order -->
            <xsl:when test="local-name($object) = 'textobject' and
                            ../imageobject or
                            ../audioobject or
                            ../videoobject">
              <xsl:text>0</xsl:text> 
            </xsl:when>
            <!-- The phrase is used only when contains TeX Math and output is FO -->
            <xsl:when test="local-name($object)='textobject' and $object/phrase
                            and $object/@role='tex' and $stylesheet.result.type = 'fo'
                            ">
              <xsl:text>1</xsl:text> 
            </xsl:when>
            <!-- The phrase is never used -->
            <xsl:when test="local-name($object)='textobject' and $object/phrase">
              <xsl:text>0</xsl:text>
            </xsl:when>
            <xsl:when test="local-name($object)='textobject'
                            and $object/ancestor::equation ">
            <!-- The first textobject is not a reasonable fallback
                 for equation image -->
              <xsl:text>0</xsl:text>
            </xsl:when>
            <!-- The first textobject is a reasonable fallback -->
            <xsl:when test="local-name($object)='textobject'
                            and $object[not(@role) or @role!='tex']">
              <xsl:text>1</xsl:text>
            </xsl:when>
            <!-- don't use graphic when output is FO, TeX Math is used 
                 and there is math in alt element -->
            <xsl:when test="$object/ancestor::equation and 
                            $object/ancestor::equation/alt[@role='tex']
                            and $stylesheet.result.type = 'fo'">
              <xsl:text>0</xsl:text>
            </xsl:when>
            <!-- If there's only one object, use it -->
            <xsl:when test="$count = 1 and count($olist) = 1">
               <xsl:text>1</xsl:text>
            </xsl:when>
            <!-- Otherwise, see if this one is a useable graphic -->
            <xsl:otherwise>
              <xsl:choose>
                <!-- peek inside imageobjectco to simplify the test -->
                <xsl:when test="local-name($object) = 'imageobjectco'">
                  <xsl:call-template name="is.acceptable.mediaobject">
                    <xsl:with-param name="object" select="$object/imageobject"/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="is.acceptable.mediaobject">
                    <xsl:with-param name="object" select="$object"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
    
        <xsl:choose>
          <xsl:when test="$useobject='1'">
            <xsl:value-of select="$count"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="select.mediaobject.index">
              <xsl:with-param name="olist" select="$olist"/>
              <xsl:with-param name="count" select="$count + 1"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  

<!-- =============================================================== -->

<xsl:template match="@spacing">
    <xsl:choose>
      <xsl:when test=". = 'compact'"/>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>
  
<xsl:template match="articleinfo|bookinfo|setinfo">
  <xsl:copy>
    <xsl:choose>
      <xsl:when test="not(date)">
        <xsl:call-template name="date">
          <xsl:with-param name="recreate" select="1"/>
        </xsl:call-template>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="date[processing-instruction()]">
        <xsl:call-template name="date">
          <xsl:with-param name="node" select="date"/>
          <xsl:with-param name="recreate" select="1"/>
        </xsl:call-template>
        <xsl:apply-templates select="node()[not(self::date)]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="date">
          <xsl:with-param name="node" select="date"/>
        </xsl:call-template>
        <xsl:apply-templates select="node()[not(self::date)]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:copy>
</xsl:template>

<xsl:template name="date">
  <xsl:param name="node" select="."/>
  <xsl:param name="recreate" select="0"/>
  <xsl:variable name="contents" select="normalize-space(.)"/>
  <xsl:variable name="pi.format">
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis" select="$node/processing-instruction('dbtimestamp')"/>
      <xsl:with-param name="attribute">format</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <!-- Partly taken from epub3/epub3-element-mods.xsl -->
  <xsl:variable name="normalized" 
                select="translate($node, '0123456789', '##########')"/>

  <xsl:variable name="date.ok">
    <xsl:choose>
      <xsl:when test="$normalized = ''">0</xsl:when>
      <xsl:when test="$normalized = '####'">1</xsl:when>
      <xsl:when test="$normalized = '####-##'">1</xsl:when>
      <xsl:when test="$normalized = '####-##-##'">1</xsl:when>
      <xsl:when test="$normalized = '####-##-##'">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="pi.format.ok">
    <xsl:choose>
      <xsl:when test="$pi.format = 'Y'">1</xsl:when>
      <xsl:when test="$pi.format = 'Y-m'">1</xsl:when>
      <xsl:when test="$pi.format = 'Y-m-d'">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="date">
    <xsl:choose>
      <xsl:when test="function-available('date:date-time')">
        <xsl:value-of select="date:date-time()"/>
      </xsl:when>
      <xsl:when test="function-available('date:dateTime')">
        <!-- Xalan quirk -->
        <xsl:value-of select="date:dateTime()"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="date.string"
    select="concat(date:year($date), '-',
                   date:month-in-year($date), '-',
                   date:day-in-month($date))"/>

  <xsl:message>*** date:
              node='<xsl:value-of select="local-name($node)"/>'
             xpath='<xsl:call-template name="xpath.location"/>'
            string='<xsl:value-of select="$node"/>'
         pi.format='<xsl:value-of select="$pi.format"/>'
      pi.format.ok='<xsl:value-of select="$pi.format.ok"/>'
                pi=<xsl:value-of select="count($node/processing-instruction())"/>
     string-length=<xsl:value-of select="string-length($normalized) = 10"/>
       use.pi4date='<xsl:value-of select="$use.pi4date"/>'
          recreate='<xsl:value-of select="$recreate"/>'
      current date='<xsl:value-of select="$date.string"/>'
        normalized='<xsl:value-of select="$normalized"/>'
           date.ok='<xsl:value-of select="$date.ok"/>'
    date:date-time='<xsl:value-of select="function-available('date:date-time')"/>'
     date:dateTime='<xsl:value-of select="function-available('date:dateTime')"/>'
  </xsl:message>

    <date>
      <xsl:choose>
        <xsl:when test="$recreate = 1 and $date.ok = 0">
          <xsl:choose>
            <xsl:when test="$use.pi4date != 0">
              <xsl:choose>
                <xsl:when test="$pi.format.ok != 0">
                  <xsl:copy-of select="$node/processing-instruction('dbtimestamp')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:processing-instruction name="dbtimestamp">format="%Y-%m-%d"</xsl:processing-instruction>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$date.string"/>
            </xsl:otherwise>
          </xsl:choose>
          
        </xsl:when>
        <xsl:when test="$recreate = 0 and $date.ok = 0">
          <xsl:message>
            <xsl:text>WARNING: wrong metadata date format. </xsl:text>
            <xsl:text>It must be in one of these forms: </xsl:text>
            <xsl:text>YYYY, YYYY-MM, or YYYY-MM-DD.</xsl:text>
            <xsl:text> Using current date.</xsl:text>
          </xsl:message>
          <xsl:value-of select="$date.string"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$node"/>
        </xsl:otherwise>
      </xsl:choose>
    </date>
</xsl:template>

<xsl:template match="mediaobject">
  <xsl:variable name="olist" select="imageobject"/>
  <xsl:variable name="object.index">
    <xsl:call-template name="select.mediaobject.index">
      <xsl:with-param name="olist" select="$olist"/>
      <xsl:with-param name="count" select="1"/>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:variable name="object" select="$olist[position() = $object.index]"/>

  <xsl:copy>
    <xsl:apply-templates select="$object"/>
  </xsl:copy>
</xsl:template>

  <xsl:template match="imagedata">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="fileref">
        <xsl:value-of select="concat($img.src.path, @fileref)"/>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>
 

<xsl:template match="xref" name="xref">
    <xsl:variable name="targets" select="key('id',@linkend)"/>
    <xsl:variable name="target" select="$targets[1]"/>
    <xsl:variable name="refelem" select="local-name($target)"/>
    <xsl:variable name="target.book" select="$target/ancestor-or-self::book"/>
    <xsl:variable name="this.book" select="ancestor-or-self::book"/>

    <!--<xsl:message>xref
     @linkend = <xsl:value-of select="@linkend"/>
   refelement = <xsl:value-of select="$refelem"/>
    </xsl:message>-->

    <xsl:choose>
      <xsl:when test="generate-id($target.book) = generate-id($this.book)">
        <!-- xref points into the same book -->
        <xsl:copy-of select="self::xref"/>
      </xsl:when>
      <xsl:otherwise>
        <phrase>
          <xsl:attribute name="role">
            <xsl:text>externalbook-</xsl:text>
            <xsl:value-of select="@linkend"/>
          </xsl:attribute>
        <xsl:text>&#8220;</xsl:text>
          <xsl:choose>
            <xsl:when test="$target/title">
              <xsl:value-of select="normalize-space($target/title)"/>
            </xsl:when>
            <xsl:when test="$target/bookinfo/title">
              <xsl:value-of select="normalize-space($target/bookinfo/title)"/>
            </xsl:when>
          </xsl:choose>
          
          <xsl:text>&#8221; (</xsl:text>
        <xsl:if
          test="$target/self::sect1 or
          $target/self::sect2 or
          $target/self::sect3 or
          $target/self::sect4">
          <xsl:text>Chapter &#8220;</xsl:text>
          <xsl:value-of select="($target/ancestor-or-self::chapter |
            $target/ancestor-or-self::appendix |
            $target/ancestor-or-self::preface)[1]/title"/>
          <xsl:text>&#8221;, </xsl:text>
        </xsl:if>
        <xsl:text>&#x2191;</xsl:text>
        <xsl:value-of select="normalize-space($target.book/bookinfo/title)"/>
        <xsl:text>)</xsl:text>
        </phrase>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
