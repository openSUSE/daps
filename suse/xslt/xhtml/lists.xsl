<?xml version="1.0" encoding="ASCII"?>
<!-- 
   Purpose:  Contains templates specific to list elements

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">


<!-- Template to omit mini tocs from Provo -->
<xsl:template match="itemizedlist[@role='subtoc']">
  <xsl:choose>
     <xsl:when test="$provo.minitoc='0'"/>
     <xsl:otherwise>
        <xsl:apply-imports/>
     </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="orderedlist/listitem">
  <li>
    <xsl:if test="@override">
      <xsl:attribute name="value">
        <xsl:value-of select="@override"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@id or @xml:id">
       <xsl:attribute name="id">
         <xsl:call-template name="object.id"/>
       </xsl:attribute>
    </xsl:if>

    <!-- we can't just drop the anchor in since some browsers (Opera)
         get confused about line breaks if we do. So if the first child
         is a para, assume the para will put in the anchor. Otherwise,
         put the anchor in anyway. -->
    <!--<xsl:if test="local-name(child::*[1]) != 'para'">
      <xsl:call-template name="anchor"/>
    </xsl:if>-->

    <xsl:choose>
      <xsl:when test="$show.revisionflag != 0 and @revisionflag">
        <div class="{@revisionflag}">
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </li>
</xsl:template>


<xsl:template match="step">
  <li>
    <xsl:if test="@id or @xml:id">
       <xsl:attribute name="id">
         <xsl:call-template name="object.id"/>
       </xsl:attribute>
    </xsl:if>
<!--     <xsl:call-template name="anchor"/> -->
    <xsl:apply-templates/>
  </li>
</xsl:template>


</xsl:stylesheet>
