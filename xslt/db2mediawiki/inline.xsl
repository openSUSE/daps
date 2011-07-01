<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: inline.xsl 10300 2006-06-22 06:51:25Z toms $ -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:text="http://www.ora.com/XSLTCookbook/namespaces/text" xmlns:exslt="http://exslt.org/common"
  exclude-result-prefixes="exslt">


  <xsl:template name="replaceSpc2Nbsp">
    <xsl:param name="content" select="."/>

    <!-- FIXME -->
    <xsl:value-of select="$content"/>
  </xsl:template>


  <xsl:template name="inline.boldseq">
    <xsl:param name="contents" select="."/>

    <xsl:text>'''</xsl:text>
    <xsl:value-of select="$contents"/>
    <xsl:text>'''</xsl:text>
  </xsl:template>


  <xsl:template name="inline.italicseq">
    <xsl:param name="contents" select="."/>

    <xsl:text>''</xsl:text>
    <xsl:value-of select="$contents"/>
    <xsl:text>''</xsl:text>
  </xsl:template>


  <xsl:template name="inline.monoseq">
    <xsl:param name="contents" select="."/>

    <xsl:text>&lt;tt></xsl:text>
    <xsl:value-of select="$contents"/>
    <xsl:text>&lt;/tt></xsl:text>
  </xsl:template>


  <!-- *********************************************************** -->
  <xsl:template match="citetitle">
    <xsl:call-template name="inline.italicseq">
      <xsl:with-param name="contents">
        <xsl:apply-templates />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="citetitle" mode="wiki">
    <xsl:call-template name="inline.italicseq">
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="wiki"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>



  <xsl:template match="formalpara">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="formalpara" mode="wiki">
     <xsl:call-template name="create.wiki">
        <xsl:with-param name="content">
          <xsl:value-of select="title"/>
          <xsl:text>|</xsl:text>
          <xsl:apply-templates mode="wiki"/>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:template>

  <xsl:template match="formalpara/title">
    <xsl:call-template name="inline.boldseq"/>
    <xsl:text> </xsl:text>
  </xsl:template>
  <xsl:template match="formalpara/title" mode="wiki"/>

  <xsl:template match="para" mode="wrap">
    <xsl:call-template name="para"/>
  </xsl:template>

  <xsl:template name="para">
    <xsl:param name="content">
       <xsl:apply-templates mode="wrap"/>
    </xsl:param>

    <xsl:choose>
      <xsl:when test="$text.wrap != 0">
        <xsl:call-template name="text:wrap">
          <xsl:with-param name="input" select="normalize-space($content)"/>
          <xsl:with-param name="width" select="$text.width"/>
          <xsl:with-param name="align-width" select="$text.width + 10"/>
          <xsl:with-param name="align" select="'left'"/>
        </xsl:call-template>
        <xsl:text>&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($content)"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="following-sibling::para">
      <xsl:text>&#10;&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="para" mode="wiki">
    <xsl:variable name="textcontent">
      <xsl:apply-templates mode="wiki"/>
    </xsl:variable>

    <xsl:value-of select="normalize-space($textcontent)"/>
    <xsl:if test="following-sibling::para">
      <xsl:text>&#10;&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- *********************************************************** -->
  <xsl:template match="command" mode="wrap">
    <xsl:call-template name="inline.boldseq">
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="wrap"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="command" mode="wiki">
     <xsl:call-template name="create.wiki">
        <xsl:with-param name="content">
          <xsl:apply-templates mode="wiki"/>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:template>

  <xsl:template match="email" mode="wrap">
    <xsl:variable name="text">
      <xsl:apply-templates mode="wrap"/>
    </xsl:variable>

    <xsl:call-template name="inline.monoseq">
      <xsl:with-param name="content">
        <xsl:text>&lt;[mailto:</xsl:text>
        <xsl:value-of select="$text"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$text"/>
        <xsl:text>]&gt;</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="email" mode="wiki">
     <xsl:call-template name="create.wiki">
        <xsl:with-param name="content">
          <xsl:apply-templates mode="wiki"/>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:template>


  <xsl:template match="emphasis" mode="wrap">
    <xsl:call-template name="inline.italicseq">
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="wrap"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="emphasis[@role='bold']" mode="wrap">
    <xsl:call-template name="inline.boldseq">
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="wrap"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="emphasis" mode="wiki">
    <xsl:choose>
      <xsl:when test="@role='bold'">
         <xsl:call-template name="inline.boldseq">
            <xsl:with-param name="contents">
            <xsl:apply-templates mode="wiki"/>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
         <xsl:call-template name="inline.italicseq">
            <xsl:with-param name="contents">
            <xsl:apply-templates mode="wiki"/>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="envar" mode="wrap">
    <xsl:call-template name="inline.monoseq">
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="wrap"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="envar" mode="wiki">
     <xsl:call-template name="create.wiki">
        <xsl:with-param name="content">
          <xsl:apply-templates mode="wiki"/>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:template>

  <xsl:template match="filename" mode="wrap">
    <xsl:variable name="textcontent">
      <xsl:apply-templates mode="wrap"/>
    </xsl:variable>

    <xsl:call-template name="inline.monoseq">
      <xsl:with-param name="contents">
        <xsl:value-of select="translate($textcontent, ' ', '&amp;nbsp;')"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="filename" mode="wiki">
     <xsl:call-template name="create.wiki">
        <xsl:with-param name="content">
          <xsl:apply-templates mode="wiki"/>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:template>


  <xsl:template match="guibutton|guiicon|guilabel" mode="wrap">
    <xsl:apply-templates mode="wrap"/>
  </xsl:template>
  <xsl:template match="guibutton|guiicon|guilabel" mode="wiki">
     <xsl:call-template name="create.wiki">
        <xsl:with-param name="content">
          <xsl:apply-templates mode="wiki"/>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:template>


  <xsl:template match="guimenu|guisubmenu" mode="wrap">
    <xsl:variable name="textcontent">
      <xsl:apply-templates mode="wrap"/>
    </xsl:variable>

    <xsl:call-template name="inline.italicseq">
      <xsl:with-param name="contents">
        <xsl:value-of select="$textcontent"/>
        <!-- FIXME -->
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="guimenu|guisubmenu" mode="wiki">
     <xsl:call-template name="create.wiki">
        <xsl:with-param name="content">
          <xsl:apply-templates mode="wiki"/>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:template>


  <xsl:template match="keycap" mode="wrap">
    <xsl:call-template name="inline.italicseq">
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="wrap"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="keycap" mode="wiki">
     <xsl:call-template name="create.wiki">
        <xsl:with-param name="content">
          <xsl:apply-templates mode="wiki"/>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:template>

  
  <xsl:template name="return.joinchar">
    <xsl:param name="node" select="."/>
    <xsl:variable name="action" select="$node/@action"/>
    
    <xsl:choose>
        <xsl:when test="$action='seq'">
          <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:when test="$action='simul'"> + </xsl:when>
        <xsl:when test="$action='press'"> - </xsl:when>
        <xsl:when test="$action='click'"> - </xsl:when>
        <xsl:when test="$action='double-click'">-</xsl:when>
        <xsl:when test="$action='other'"/>
        <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  

  <xsl:template match="keycombo" mode="wrap">
    <xsl:variable name="joinchar">
      <xsl:call-template name="return.joinchar"/>
    </xsl:variable>
    
    <xsl:for-each select="*">
      <xsl:if test="position()>1">
        <xsl:value-of select="$joinchar"/>
      </xsl:if>
      <xsl:apply-templates select="current()" mode="wrap"/>
    </xsl:for-each> 
  </xsl:template>

  <xsl:template match="keycombo" mode="wiki">
    <xsl:variable name="joinchar">
      <xsl:call-template name="return.joinchar"/>
    </xsl:variable>
    
    <xsl:for-each select="*">
      <xsl:if test="position()>1">
        <xsl:value-of select="$joinchar"/>
      </xsl:if>
      <xsl:apply-templates select="current()" mode="wiki"/>
    </xsl:for-each> 
  </xsl:template>


  <xsl:template match="literal" mode="wrap">
    <xsl:call-template name="inline.monoseq"/>
  </xsl:template>
  <xsl:template match="literal" mode="wiki">
     <xsl:call-template name="create.wiki">
        <xsl:with-param name="content">
          <xsl:apply-templates mode="wiki"/>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:template>


  <xsl:template match="menuchoice" mode="wrap">
    <xsl:variable name="shortcut" select="./shortcut"/>
    <xsl:call-template name="process.menuchoice"/>
    <xsl:if test="$shortcut">
      <xsl:text> (</xsl:text>
      <xsl:apply-templates select="$shortcut"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template match="menuchoice" mode="wiki">
    <xsl:variable name="shortcut" select="./shortcut"/>
    <xsl:call-template name="process.menuchoice"/>
    <xsl:if test="$shortcut">
      <xsl:text> (</xsl:text>
      <xsl:apply-templates select="$shortcut" mode="wiki"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>


  <xsl:template match="option" mode="wrap">
    <xsl:choose>
      <xsl:when test="parent::para">
        <xsl:call-template name="inline.monoseq"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="wrap"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="option" mode="wiki">
     <xsl:call-template name="create.wiki">
        <xsl:with-param name="content">
          <xsl:apply-templates mode="wiki"/>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:template>


  <xsl:template match="phrase" mode="wrap">
    <xsl:apply-templates mode="wrap"/>
  </xsl:template>
  <xsl:template match="phrase" mode="wiki">
     <xsl:apply-templates mode="wiki"/>
  </xsl:template>


  <xsl:template match="productname" mode="wrap">
    <xsl:apply-templates mode="wrap"/>
  </xsl:template>
  <xsl:template match="productname" mode="wiki">
     <xsl:call-template name="create.wiki">
        <xsl:with-param name="content">
          <xsl:apply-templates mode="wiki"/>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:template>

  <xsl:template match="quote" mode="wrap">
    <xsl:text>»</xsl:text>
    <xsl:apply-templates mode="wrap"/>
    <xsl:text>«</xsl:text>
  </xsl:template>
  <xsl:template match="quote" mode="wiki">
     <xsl:call-template name="create.wiki">
        <xsl:with-param name="content">
          <xsl:apply-templates mode="wiki"/>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:template>


  <xsl:template name="process.menuchoice">
    <xsl:param name="nodelist"
      select="guibutton|guiicon|guilabel|guimenu|guimenuitem|guisubmenu|interface"/>
    <!-- not(shortcut) -->
    <xsl:param name="count" select="1"/>

    <xsl:choose>
      <xsl:when test="$count>count($nodelist)"/>
      <xsl:when test="$count=1">
        <xsl:apply-templates select="$nodelist[$count=position()]" mode="wrap"/>
        <xsl:call-template name="process.menuchoice">
          <xsl:with-param name="nodelist" select="$nodelist"/>
          <xsl:with-param name="count" select="$count+1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="node" select="$nodelist[$count=position()]"/>
        <xsl:copy-of select="$menuchoice.separator"/>
        <xsl:apply-templates select="$node" mode="wrap"/>
        <xsl:call-template name="process.menuchoice">
          <xsl:with-param name="nodelist" select="$nodelist"/>
          <xsl:with-param name="count" select="$count+1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- We don't want to have remarks in the result wiki text -->
  <xsl:template match="remark" mode="wrap"/>
  <xsl:template match="remark" mode="wiki"/>
  <xsl:template match="remark"/>

  <xsl:template match="replaceable" mode="wrap">
    <xsl:call-template name="inline.italicseq"/>
  </xsl:template>
  <xsl:template match="replaceable" mode="wiki">
     <xsl:call-template name="create.wiki">
        <xsl:with-param name="content">
          <xsl:apply-templates mode="wiki"/>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:template>

  <xsl:template match="systemitem" mode="wrap">
    <xsl:call-template name="inline.monoseq"/>
  </xsl:template>
  <xsl:template match="systemitem" mode="wiki">
     <xsl:call-template name="create.wiki">
        <xsl:with-param name="content">
          <xsl:apply-templates mode="wiki"/>
        </xsl:with-param>
     </xsl:call-template>
  </xsl:template>

  <xsl:template match="ulink" name="ulink" mode="wrap">
    <xsl:choose>
      <xsl:when test="count(child::node())=0">
        <xsl:value-of select="@url"/>
      </xsl:when>
      <xsl:when test="string(.) = @url">
        <xsl:value-of select="@url"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="@url"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="ulink" mode="wiki">
    <xsl:call-template name="ulink"/>
  </xsl:template>

  <xsl:template match="*" mode="wrap">
    <xsl:call-template name="notemplatematches">
        <xsl:with-param name="mode">wrap</xsl:with-param>
     </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
