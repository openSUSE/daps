<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   version="1.0">

   <xsl:output method="text"/>

   <xsl:include href="../common/xpath.location.xsl"/>

   <xsl:template name="print.debug">
      <xsl:param name="text"/>
      <xsl:param name="showcontents" select="1"/>

      <xsl:message>
         <xsl:text>* Issue: </xsl:text>
         <xsl:value-of select="$text"/>
         <xsl:text>&#10;  XPath: </xsl:text>
         <xsl:call-template name="xpath.location"/>
         <xsl:if test="$showcontents != 0">
            <xsl:text/>
            <xsl:value-of
               select="concat(' = &quot;', normalize-space(.), '&quot;')"
            />
         </xsl:if>
      </xsl:message>
   </xsl:template>


   <xsl:template match="text()"/>

   <xsl:template match="mediaobject">
      <xsl:choose>
         <xsl:when test="count(imageobject) = 2">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:call-template name="print.debug">
               <xsl:with-param name="text">mediaobject does not contain
                  2 imageobjects</xsl:with-param>
               <xsl:with-param name="showcontents" select="0"/>
            </xsl:call-template>

            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="imageobject">
      <xsl:choose>
         <xsl:when test="@role">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:call-template name="print.debug">
               <xsl:with-param name="text">imageobject does not contain
                  @role attribute.</xsl:with-param>
               <xsl:with-param name="showcontents" select="0"/>
            </xsl:call-template>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="imagedata">
      <xsl:choose>
         <xsl:when test="@width = ''">
            <xsl:call-template name="print.debug">
               <xsl:with-param name="text">Attribute @width can not be
                  empty.</xsl:with-param>
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="contains(@width, ' ')">
            <xsl:call-template name="print.debug">
               <xsl:with-param name="text">Attribute @width must not
                  contain spaces.</xsl:with-param>
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="not(contains(@width, '%'))">
            <xsl:call-template name="print.debug">
               <xsl:with-param name="text">Attribute @width should
                  contain a percentage value.</xsl:with-param>
            </xsl:call-template>
         </xsl:when>
      </xsl:choose>

   </xsl:template>

   <!--<xsl:template match="para">
        <xsl:apply-templates/>
    </xsl:template>-->

   <xsl:template match="bridgehead">
      <xsl:call-template name="print.debug">
         <xsl:with-param name="text">
            <xsl:text>Remove bridgehead and wrap the following elements </xsl:text>
            <xsl:text>inside a sect1, sect2 or sect3.</xsl:text>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

   <xsl:template match="guimenu[1]">
      <xsl:variable name="textnode"
         select="normalize-space(following-sibling::text())"/>
      <xsl:variable name="siblings" select="following-sibling::guimenu"/>

      <xsl:choose>
         <xsl:when
            test="$textnode and $siblings and
                            local-name($siblings[1])='guimenu'">
            <xsl:call-template name="print.debug">
               <xsl:with-param name="text">
                  <xsl:text>Consecutive guimenus, separated by character, </xsl:text>
                  <xsl:text>must be enclosed with keycombo</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:when>
      </xsl:choose>

      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="keycap[1]">
      <xsl:variable name="textnode"
         select="normalize-space(following-sibling::text())"/>
      <xsl:variable name="siblings" select="following-sibling::keycap"/>

      <!--<xsl:message>
            keycap[1]: "<xsl:value-of select="normalize-space(($siblings)[1])"/>"
                       "<xsl:value-of select="following-sibling::keycap"/>"
        </xsl:message>-->


      <xsl:choose>
         <xsl:when
            test="$textnode and $siblings and
                            local-name($siblings[1])='keycap'">
            <xsl:call-template name="print.debug">
               <xsl:with-param name="text">
                  <xsl:text>Consecutive keycaps, separated by character, </xsl:text>
                  <xsl:text>must be enclosed with keycombo</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:when>
      </xsl:choose>

      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="filename[1]">
      <xsl:variable name="textnode"
         select="normalize-space(following-sibling::text())"/>
      <xsl:variable name="siblings" select="following-sibling::filename"/>
      <xsl:variable name="notallowedchars">/,:;</xsl:variable>

      <!--        <xsl:message>filename[1]="<xsl:value-of select="$textnode"/>" <xsl:value-of select="contains($notallowedchars, $textnode)"/></xsl:message>
-->
      <xsl:choose>
         <xsl:when
            test="contains($notallowedchars, $textnode) and $siblings">
            <xsl:call-template name="print.debug">
               <xsl:with-param name="text">
                  <xsl:text>Consecutive filenames, separated by a character, </xsl:text>
                  <xsl:text>must be collected into one filename</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:when>
      </xsl:choose>

      <xsl:apply-templates/>

   </xsl:template>

   <xsl:template match="chapter/*[local-name(.) != 'sect1'][last()][local-name(.) = 'itemizedlist']">
      <xsl:call-template name="print.debug">
         <xsl:with-param name="showcontents" select="0"/>
         <xsl:with-param name="text">
            <xsl:text>The last itemizedlist before sect1 looks like a minitoc. </xsl:text>
            <xsl:text>Better replace/remove it?</xsl:text>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="itemizedlist[@role='subtoc']">
      <xsl:call-template name="print.debug">
         <xsl:with-param name="showcontents" select="0"/>
         <xsl:with-param name="text">
            <xsl:text>This itemizedlist seems like a minitoc. </xsl:text>
            <xsl:text>Better replace/remove it?</xsl:text>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="step[@performance='required']">
      <xsl:call-template name="print.debug">
         <xsl:with-param name="showcontents" select="0"/>
         <xsl:with-param name="text">
            <xsl:text>This step contains needless default attribute @performance='required'. </xsl:text>
            <xsl:text>Better remove it.</xsl:text>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="itemizedlist[@*]">
      <xsl:if test="@mark='bullet'">
         <xsl:call-template name="print.debug">
            <xsl:with-param name="showcontents" select="0"/>
            <xsl:with-param name="text">
               <xsl:text>Needless default attribute @mark='bullet'. </xsl:text>
               <xsl:text>Better remove it.</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:if test="@spacing='normal'">
         <xsl:call-template name="print.debug">
            <xsl:with-param name="showcontents" select="0"/>
            <xsl:with-param name="text">
               <xsl:text>Needless default attribute @spacing='normal'. </xsl:text>
               <xsl:text>Better remove it.</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="figure[@pgwide='0']">
      <xsl:call-template name="print.debug">
         <xsl:with-param name="showcontents" select="0"/>
         <xsl:with-param name="text">
            <xsl:text>Needless default attribute @pgwide='0'. </xsl:text>
            <xsl:text>Better remove it.</xsl:text>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="table[@*]">
      <xsl:if test="@frame='topbot'">
         <xsl:call-template name="print.debug">
            <xsl:with-param name="showcontents" select="0"/>
            <xsl:with-param name="text">
               <xsl:text>Needless default attribute @frame='topbot'. </xsl:text>
               <xsl:text>Better remove it.</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:if test="@pgwide='0'">
         <xsl:call-template name="print.debug">
            <xsl:with-param name="showcontents" select="0"/>
            <xsl:with-param name="text">
               <xsl:text>Needless default attribute @pgwide='0'. </xsl:text>
               <xsl:text>Better remove it.</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="row[@rowsep='1']">
      <xsl:call-template name="print.debug">
         <xsl:with-param name="showcontents" select="0"/>
         <xsl:with-param name="text">
            <xsl:text>Attribute @rowsep='1'? </xsl:text>
            <xsl:text>Is it really needed?</xsl:text>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="entry[@colname='1']">
      <xsl:call-template name="print.debug">
         <xsl:with-param name="showcontents" select="0"/>
         <xsl:with-param name="text">
            <xsl:text>Attribute @colname='1'. </xsl:text>
            <xsl:text>Is it really needed?</xsl:text>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
   </xsl:template>
      
   <xsl:template match="xref[@xrefstyle='HeadingOnPage']">
      <xsl:call-template name="print.debug">
         <xsl:with-param name="showcontents" select="0"/>
         <xsl:with-param name="text">
            <xsl:text>Attribute @xrefstyle='HeadingOnPage'. </xsl:text>
            <xsl:text>Urgh. Remove this beast, please.</xsl:text>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
</xsl:stylesheet>
