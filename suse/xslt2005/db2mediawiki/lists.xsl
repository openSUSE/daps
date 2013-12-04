<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: $ -->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


   <xsl:template match="variablelist">
      <xsl:param name="char" select="''"/>
      <xsl:param name="nested" select="false()"/>

      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates>
         <xsl:with-param name="char" select="$char"/>
         <xsl:with-param name="nested"
            select="boolean(parent::listitem) or boolean(parent::step)"
         />
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="variablelist" mode="wiki">
      <xsl:param name="char" select="''"/>
      <xsl:param name="nested" select="false()"/>

      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates mode="wiki">
         <xsl:with-param name="char" select="$char"/>
         <xsl:with-param name="nested"
            select="boolean(parent::listitem) or boolean(parent::step)"
         />
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="variablelist/title" mode="wiki">
      <xsl:text>&#10;</xsl:text>
      <xsl:call-template name="inline.boldseq">
         <xsl:with-param name="contents">
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:with-param>
      </xsl:call-template>
      <!--<xsl:text>&#10;</xsl:text>-->
   </xsl:template>

   <xsl:template match="varlistentry">
      <xsl:param name="char" select="''"/>
      <xsl:param name="nested" select="false()"/>

      <!--<xsl:message>varlistentry: »<xsl:value-of select="$char"/>«</xsl:message>-->
      <xsl:value-of select="concat('&#10;', $char, ';')"/>
      <xsl:apply-templates select="term"/>

      <xsl:value-of select="concat('&#10;', $char, ':')"/>
      <xsl:apply-templates select="listitem">
         <xsl:with-param name="char" select="concat($char, ':')"/>
         <xsl:with-param name="nested" select="$nested"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="varlistentry" mode="wiki">
      <xsl:param name="char" select="''"/>
      <xsl:param name="nested" select="false()"/>

      <!--<xsl:message>varlistentry: »<xsl:value-of select="$char"/>«</xsl:message>-->
      <xsl:value-of select="concat('&#10;', $char, ';')"/>
      <xsl:apply-templates select="term"/>

      <xsl:value-of select="concat('&#10;', $char, ':')"/>
      <xsl:apply-templates select="listitem"  mode="wiki">
         <xsl:with-param name="char" select="concat($char, ':')"/>
         <xsl:with-param name="nested" select="$nested"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="varlistentry/text()"/>

   <xsl:template match="term">
      <xsl:variable name="context">
         <xsl:apply-templates mode="wrap"/>
      </xsl:variable>

      <xsl:value-of select="normalize-space($context)"/>
   </xsl:template>
   <xsl:template match="term" mode="wiki">
      <xsl:variable name="context">
         <xsl:apply-templates mode="wiki"/>
      </xsl:variable>

      <xsl:value-of select="normalize-space($context)"/>
   </xsl:template>

   <xsl:template match="varlistentry/listitem">
      <xsl:param name="char" select="''"/>

      <!--<xsl:message>varlistentry/listitem: »<xsl:value-of select="$char"
         />«</xsl:message>-->
      <xsl:apply-templates>
         <xsl:with-param name="char" select="$char"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="varlistentry/listitem" mode="wiki">
      <xsl:param name="char" select="''"/>

      <!--<xsl:message>varlistentry/listitem: »<xsl:value-of select="$char"
         />«</xsl:message>-->
      <xsl:apply-templates mode="wiki">
         <xsl:with-param name="char" select="$char"/>
      </xsl:apply-templates>
   </xsl:template>


   <!--<xsl:template match="listitem/para" mode="wiki">
      <xsl:param name="char" select="''"/>
      
      <xsl:value-of select="$char"/>
      <xsl:call-template name="para">
         <xsl:with-param name="content">
            <xsl:apply-templates mode="wiki"/>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>-->

  <!-- *********************************************************** -->
   <xsl:template match="orderedlist">
      <xsl:param name="char" select="''"/>
      <xsl:param name="nested" select="false()"/>

      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates>
         <xsl:with-param name="char">
            <xsl:value-of select="concat($char, '#')"/>
         </xsl:with-param>
         <xsl:with-param name="nested" select="boolean(parent::listitem) or boolean(parent::step)"/>
      </xsl:apply-templates>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>
   <xsl:template match="orderedlist" mode="wiki">
      <xsl:param name="char" select="''"/>
      <xsl:param name="nested" select="false()"/>

      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates mode="wiki">
         <xsl:with-param name="char"   select="concat($char, '#')"/>         
         <xsl:with-param name="nested" select="boolean(parent::listitem) or boolean(parent::step)"/>
      </xsl:apply-templates>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>


  <!-- *********************************************************** -->
   <xsl:template match="itemizedlist">
      <xsl:param name="char" select="''"/>
      <xsl:param name="nested" select="false()"/>

      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates>
         <xsl:with-param name="char"   select="concat($char, '*')"/>         
         <xsl:with-param name="nested" select="boolean(parent::listitem) or boolean(parent::step)"/>
      </xsl:apply-templates>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>
   <xsl:template match="itemizedlist" mode="wiki">
      <xsl:param name="char" select="''"/>
      <xsl:param name="nested" select="false()"/>

      <xsl:message> itemizedlist </xsl:message>
      
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates mode="wiki">
         <xsl:with-param name="char"   select="concat($char, '*')"/>         
         <xsl:with-param name="nested" select="boolean(parent::listitem) or boolean(parent::step)"/>
      </xsl:apply-templates>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>



   <xsl:template match="listitem">
      <xsl:param name="char" select="''"/>
      <xsl:param name="nested" select="false()"/>

      <xsl:if test="preceding-sibling::listitem">
         <xsl:text>&#10;</xsl:text>
      </xsl:if>
      <xsl:value-of select="$char"/>
      <xsl:apply-templates>
         <xsl:with-param name="char">
            <xsl:value-of select="$char"/>
         </xsl:with-param>
      </xsl:apply-templates>

      <xsl:choose>
         <xsl:when test="parent::itemizedlist">
            <xsl:text>&#10;</xsl:text>
         </xsl:when>
         <xsl:when test="parent::orderedlist">

         </xsl:when>
      </xsl:choose>

      <xsl:if test="$nested">
         <xsl:text>&#10;</xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="listitem" mode="wiki">
      <xsl:param name="char" select="''"/>
      <xsl:param name="nested" select="false()"/>

      <xsl:message> listitem: <xsl:value-of select="$char"/> <xsl:value-of select="$nested"/> </xsl:message>
      
      <!--<xsl:if test="preceding-sibling::listitem">
         <xsl:text>&#10;</xsl:text>
      </xsl:if>-->
      <xsl:value-of select="$char"/>
      <xsl:apply-templates mode="wiki">
         <xsl:with-param name="char" select="$char"/>         
      </xsl:apply-templates>

      <xsl:choose>
         <xsl:when test="parent::itemizedlist">
            <xsl:text>&#10;</xsl:text>
         </xsl:when>
         <xsl:when test="parent::orderedlist">
            <xsl:text>&#10;</xsl:text>
         </xsl:when>
      </xsl:choose>

      <xsl:if test="$nested">
         <xsl:text>&#10;</xsl:text>
      </xsl:if>
   </xsl:template>


  <!-- *********************************************************** -->
   <xsl:template match="procedure">
      <xsl:text>&#10;&#10;</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="procedure" mode="wiki">
      <xsl:text>&#10;&#10;</xsl:text>
      <xsl:apply-templates mode="wiki"/>
   </xsl:template>

   <xsl:template match="procedure/title" name="proceduretitle">
      <xsl:variable name="text">
         <xsl:call-template name="inline.boldseq">
            <xsl:with-param name="contents" select="concat('Procedure: ', .)"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="concat($text, '&#10;')"/>
   </xsl:template>
   <xsl:template match="procedure/title" mode="wiki">
      <xsl:call-template name="proceduretitle"/>
   </xsl:template>

   <xsl:template match="step">
      <xsl:param name="char" select="''"/>
      <xsl:param name="nested" select="false()"/>

      <xsl:value-of select="concat($char, '#')"/>
      <xsl:apply-templates>
         <xsl:with-param name="char" select="concat($char, ':')"/>
      </xsl:apply-templates>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>
   <xsl:template match="step" mode="wiki">
      <xsl:param name="char" select="''"/>
      <xsl:param name="nested" select="false()"/>

      <xsl:value-of select="concat($char, '#')"/>
      <xsl:apply-templates mode="wiki">
         <xsl:with-param name="char" select="concat($char, ':')"/>
      </xsl:apply-templates>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>


</xsl:stylesheet>