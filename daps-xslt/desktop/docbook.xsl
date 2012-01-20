<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common" xmlns:suse="urn:x-suse:namespace:1.0"
  extension-element-prefixes="exsl suse" version="1.0">

  <xsl:import href="../misc/rootid.xsl"/>
  <xsl:output method="text" encoding="UTF-8" />

  <xsl:include href="../profiling/suse-pi.xsl"/>
  <xsl:include href="filename.xsl" />
  <xsl:include href="write.text.chunk.xsl" />

  <xsl:strip-space elements="*" />
  <xsl:preserve-space elements="title"/>


  <!-- use.id.as.filename: Use id attribute as filename instead of
                         "standard" numbering schema            -->
  <xsl:param name="use.id.as.filename" select="1" />

  <!-- desktop.ext: Each filename contains this suffix            -->
  <xsl:param name="desktop.ext" select="'.desktop'" />

  <!-- html.ext: suffix for HTML                                  -->
  <xsl:param name="html.ext" select="'.html'" />

  <!-- root.filename: The "main" file for all desktop files       -->
  <xsl:param name="root.filename" select="concat('index',$desktop.ext)" />

  <!-- desktop.encoding: Use selected encoding for each file      -->
  <xsl:param name="desktop.encoding" select="'UTF-8'" />

  <!-- docpath: Inserts string in desktop files DocPath           -->
  <xsl:param name="docpath" select="'@PATH@/'" />

  <!-- directory.filename: The filename for desktop files for
                         directories                            -->
  <xsl:param name="directory.filename" select="'.directory'" />

  <!-- base.dir: Sets the output directory for each desktop file -->
  <xsl:param name="base.dir" select="'desktop/'" />


  <xsl:param name="generate.index" select="1" />
  <xsl:param name="chunk.section.depth" select="1" />
  <xsl:param name="chunk.first.sections" select="0" />


  <!-- ********************************************************** -->
  <xsl:template match="/">
    <xsl:if test="$docpath = ''">
      <xsl:message terminate="yes">
        <xsl:text>ERROR: You must specify the path which&#10;</xsl:text>
        <xsl:text>       contains the corresponding HTML files.</xsl:text>
        <xsl:text>SOLUTION: Try it with --stringparam docpath "YOUR_PATH"</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:message>Generating desktop files </xsl:message>
    <xsl:apply-imports/>
  </xsl:template>

  
  <xsl:template match="set">
    <xsl:call-template name="create.directory"/>
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="book">
    <xsl:param name="dir" select="''" />
    <xsl:variable name="directory">
      <xsl:apply-templates select="." mode="recursive-chunk-filename" />
    </xsl:variable>

    <xsl:message>*** Book <xsl:value-of
      select="normalize-space((bookinfo/title|title)[last()])"/></xsl:message>

    <xsl:call-template name="create.directory">
      <xsl:with-param name="dir" select="concat($directory, '/')" />
    </xsl:call-template>

    <xsl:apply-templates>
      <xsl:with-param name="dir" select="concat($directory, '/')" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="article">
    <xsl:param name="dir" select="''" />
    <xsl:variable name="directory">
      <xsl:apply-templates select="." mode="recursive-chunk-filename" />
    </xsl:variable>

    <xsl:call-template name="create.directory">
      <xsl:with-param name="dir" select="$dir" />
    </xsl:call-template>

    <xsl:apply-templates>
      <xsl:with-param name="dir" select="$dir" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="part">
    <xsl:param name="dir" select="''" />
    
    <xsl:message>** Part <xsl:value-of
      select="normalize-space((bookinfo/title|title)[last()])"/></xsl:message>
    
    
    <xsl:variable name="directory">
      <xsl:value-of select="$dir"/>
      <xsl:apply-templates select="." mode="recursive-chunk-filename" />
      <xsl:text>/</xsl:text>
    </xsl:variable>

    <xsl:call-template name="create.directory">
      <xsl:with-param name="dir" select="$directory" />
    </xsl:call-template>

    <xsl:apply-templates>
      <xsl:with-param name="dir" select="$directory" />
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template match="chapter|appendix">
    <xsl:param name="dir" select="''" />
    
    <xsl:call-template name="create.directory">
      <xsl:with-param name="dir" select="$dir" />
    </xsl:call-template>

    <xsl:apply-templates>
      <xsl:with-param name="dir" select="$dir" />
    </xsl:apply-templates>
  </xsl:template>


  <xsl:template match="article/sect1">
    <xsl:param name="dir" select="''" />
    
    <xsl:call-template name="create.directory">
      <xsl:with-param name="dir" select="$dir" />
    </xsl:call-template>

    <!--<xsl:message>>>>> article/sect1: 
      dir:      "<xsl:value-of select="$dir"/>"
      filename: "<xsl:apply-templates select="."
        mode="recursive-chunk-filename" />"
    </xsl:message>-->

    <xsl:apply-templates>
      <xsl:with-param name="dir" select="$dir" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="title" mode="title">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
 
  <xsl:template match="prefix">
    <xsl:param name="dir" select="''" />

<!--    <xsl:message> prefix: "<xsl:value-of select="title" />":
        <xsl:apply-templates select="." mode="recursive-chunk-filename" />
    </xsl:message>
-->    
    <xsl:apply-templates />
  </xsl:template>


  <!--
  <xsl:template match="sect1|sect2|sect3|sect4|sect5">
    <xsl:param name="dir" select="''"/>

   <xsl:message>   <xsl:value-of select="name(.)"/>: "<xsl:value-of 
     select="title"
   />":  <xsl:apply-templates select="." mode="recursive-chunk-filename">
     <xsl:with-param name="recursive" select="true()"/>
   </xsl:apply-templates>
    </xsl:message>
    <xsl:apply-templates />
  </xsl:template>
-->

  <xsl:template match="*|text()" />

  <!-- ********************************************************** -->
  <xsl:template name="create.directory">
    <xsl:param name="dir" select="''" />
    <xsl:param name="node" select="." />

    <xsl:variable name="localdocpath">
      <xsl:value-of select="$docpath" />
      <xsl:choose>
        <xsl:when test="self::set">
          <xsl:value-of select="concat('index', $html.ext)" />
        </xsl:when>
        <xsl:when test="$use.id.as.filename and @id != ''">
          <xsl:value-of select="concat(@id, $html.ext)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." 
          mode="recursive-chunk-filename"/>
          <xsl:value-of select="$html.ext"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="$node/title">
          <xsl:apply-templates select="$node/title" mode="title" />
        </xsl:when>
        <xsl:when test="title">
          <xsl:apply-templates select="title"  mode="title"/>
        </xsl:when>
        <xsl:when test="bookinfo/title">
          <xsl:apply-templates select="bookinfo/title" mode="title" />
        </xsl:when>
        <xsl:otherwise>???</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="create.directory" 
      select="self::set or self::part or self::book or self::article"/>
    
   <!-- <xsl:message>create.directory:
    element: <xsl:value-of select="local-name($node)"/> || <xsl:value-of 
      select="local-name(.)"/>
    title:   "<xsl:value-of select="$title"/>" || <xsl:value-of 
      select="title"/>
    </xsl:message>-->
    
    <xsl:variable name="filename">
      <xsl:choose>
        <xsl:when test="$create.directory">
          <xsl:value-of select="$directory.filename" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="recursive-chunk-filename" />
          <xsl:value-of select="$desktop.ext"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    


    <!--<xsl:message>create.directory: 
      localdocpath: "<xsl:value-of select="$localdocpath" />" 
      dir: "<xsl:value-of select="$dir" />"
      title: "<xsl:value-of select="$title" />" 
      filename: "<xsl:value-of select="$filename" />"
    </xsl:message>
-->

    <xsl:call-template name="suse:writechunk">
      <xsl:with-param name="directory" select="$dir" />
      <xsl:with-param name="filename" select="$filename" />
      <xsl:with-param name="filecontent">
        <xsl:text>[Desktop Entry]&#10;</xsl:text>

        <xsl:call-template name="suse:keyvalue">
          <xsl:with-param name="key">Name</xsl:with-param>
          <xsl:with-param name="value" select="$title" />
          <xsl:with-param name="printlang" select="0" />
        </xsl:call-template>
        <xsl:call-template name="suse:keyvalue">
          <xsl:with-param name="key">Name</xsl:with-param>
          <xsl:with-param name="value" select="$title" />
          <xsl:with-param name="printlang" select="1" />
        </xsl:call-template>

        <xsl:call-template name="suse:keyvalue">
          <xsl:with-param name="key">Comment</xsl:with-param>
          <xsl:with-param name="value" select="$title" />
          <xsl:with-param name="printlang" select="0" />
        </xsl:call-template>

        <xsl:call-template name="suse:keyvalue">
          <xsl:with-param name="key">Comment</xsl:with-param>
          <xsl:with-param name="value" select="$title" />
          <xsl:with-param name="printlang" select="1" />
        </xsl:call-template>

        <xsl:choose>
          <xsl:when test="self::set">
            <xsl:text># DocPath=&#10;</xsl:text>
            <xsl:text># Icon=document2&#10;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="suse:keyvalue">
              <xsl:with-param name="key">DocPath</xsl:with-param>
              <xsl:with-param name="value" select="$localdocpath" />
            </xsl:call-template>
            <xsl:text>Icon=document2&#10;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        

        <xsl:if test="$create.directory">
          <xsl:text>X-DOC-DocumentType=text/html&#10;</xsl:text>
          <xsl:text>X-DOC-Identifier=@id@&#10;</xsl:text>
          <xsl:text>X-DOC-SearchMethod=Htdig&#10;</xsl:text>
          <xsl:text>X-DOC-SearchEnabledDefault=true&#10;</xsl:text>
        </xsl:if>
        
        <xsl:text>X-DOC-Weight=</xsl:text>
        <xsl:call-template name="suse:calcposition"/>        
      </xsl:with-param>
    </xsl:call-template>

  </xsl:template>



  <!-- ********************************************************** -->
  <xsl:template name="getdirectory">
    <xsl:param name="dir" select="''" />
    <xsl:param name="node" select="." />

    <xsl:choose>
      <xsl:when test="$dir != ''">
        <xsl:value-of select="$dir" />
        <xsl:text>/</xsl:text>
        <xsl:apply-templates select="$node" mode="recursive-chunk-filename" />
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>



  <!-- ********************************************************** -->
  <xsl:template name="suse:writechunk">
    <xsl:param name="directory" />
    <xsl:param name="filename" />
    <xsl:param name="filecontent" />

    <xsl:call-template name="write.text.chunk">
      <xsl:with-param name="filename"
        select="concat($base.dir, $directory, $filename)" />
      <xsl:with-param name="content" select="$filecontent" />
      <xsl:with-param name="encoding" select="$desktop.encoding" />
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="suse:keyvalue">
    <xsl:param name="key" />
    <xsl:param name="value" />
    <xsl:param name="printlang" select="0" />

    <xsl:value-of select="$key" />
    <xsl:if test="$printlang=1">
      <xsl:text>[</xsl:text>
      <xsl:value-of
        select="(@lang|
                 ancestor-or-self::article/@lang |
                 ancestor-or-self::book/@lang |
                 ancestor-or-self::set/@lang)[1]"
      />
      <xsl:text>]</xsl:text>
    </xsl:if>
    <xsl:text>=</xsl:text>
    <xsl:value-of select="$value" />
    <xsl:text>&#10;</xsl:text>

  </xsl:template>


  <xsl:template name="suse:calcposition">
    <xsl:param name="value">    
        <xsl:number
          count="book|article|part|preface|chapter|appendix|index|glossary|bibliography|sect1"
         level="any"/>
    </xsl:param>
    
    <!--<xsl:message>  *** <xsl:value-of select="number($value)*10"/>
      <xsl:value-of select="name()"/></xsl:message>-->
    
    <xsl:value-of select="number($value)*10"/>
</xsl:template>


</xsl:stylesheet>
