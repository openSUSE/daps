<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- Checks if an element needs to be profiled
     returns 0 (needs to be profiled) or 1 (no profiling necessary)

     Taken from the original DocBook XSL Stylesheets,
     see profiling/profile-mode.xsl
-->

<xsl:include href="pi-attribute.xsl"/>

<xsl:param name="provo.root"/>

<xsl:template name="check.profiling">
  <xsl:param name="context" select="."/>

  <xsl:variable name="arch.content">
    <xsl:if test="$context/@arch">
      <xsl:call-template name="cross.compare">
        <xsl:with-param name="a" select="$profile.arch"/>
        <xsl:with-param name="b" select="$context/@arch"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="arch.ok" select="not($context/@arch) or not($profile.arch) or
                                       $arch.content != '' or $context/@arch = ''"/>

  <xsl:variable name="condition.content">
    <xsl:if test="$context/@condition">
      <xsl:call-template name="cross.compare">
        <xsl:with-param name="a" select="$profile.condition"/>
        <xsl:with-param name="b" select="$context/@condition"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="condition.ok" select="not($context/@condition) or not($profile.condition) or
                                            $condition.content != '' or $context/@condition = ''"/>

  <xsl:variable name="conformance.content">
    <xsl:if test="$context/@conformance">
      <xsl:call-template name="cross.compare">
        <xsl:with-param name="a" select="$profile.conformance"/>
        <xsl:with-param name="b" select="$context/@conformance"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="conformance.ok" select="not($context/@conformance) or not($profile.conformance) or
                                              $conformance.content != '' or $context/@conformance = ''"/>

  <xsl:variable name="lang.content">
    <xsl:if test="$context/@lang">
      <xsl:call-template name="cross.compare">
        <xsl:with-param name="a" select="$profile.lang"/>
        <xsl:with-param name="b" select="$context/@lang"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="lang.ok" select="not($context/@lang) or not($profile.lang) or
                                       $lang.content != '' or $context/@lang = ''"/>

  <xsl:variable name="os.content">
    <xsl:if test="$context/@os">
      <xsl:call-template name="cross.compare">
        <xsl:with-param name="a" select="$profile.os"/>
        <xsl:with-param name="b" select="$context/@os"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="os.ok" select="not($context/@os) or not($profile.os) or
                                     $os.content != '' or $context/@os = ''"/>

  <xsl:variable name="revision.content">
    <xsl:if test="$context/@revision">
      <xsl:call-template name="cross.compare">
        <xsl:with-param name="a" select="$profile.revision"/>
        <xsl:with-param name="b" select="$context/@revision"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="revision.ok" select="not($context/@revision) or not($profile.revision) or
                                           $revision.content != '' or $context/@revision = ''"/>

  <xsl:variable name="revisionflag.content">
    <xsl:if test="$context/@revisionflag">
      <xsl:call-template name="cross.compare">
        <xsl:with-param name="a" select="$profile.revisionflag"/>
        <xsl:with-param name="b" select="$context/@revisionflag"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="revisionflag.ok" select="not($context/@revisionflag) or not($profile.revisionflag) or
                                               $revisionflag.content != '' or $context/@revisionflag = ''"/>

  <xsl:variable name="role.content">
    <xsl:if test="$context/@role">
      <xsl:call-template name="cross.compare">
        <xsl:with-param name="a" select="$profile.role"/>
        <xsl:with-param name="b" select="$context/@role"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="role.ok" select="not($context/@role) or not($profile.role) or
                                       $role.content != '' or $context/@role = ''"/>

  <xsl:variable name="security.content">
    <xsl:if test="$context/@security">
      <xsl:call-template name="cross.compare">
        <xsl:with-param name="a" select="$profile.security"/>
        <xsl:with-param name="b" select="$context/@security"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="security.ok" select="not($context/@security) or not($profile.security) or
                                           $security.content != '' or $context/@security = ''"/>

  <xsl:variable name="userlevel.content">
    <xsl:if test="$context/@userlevel">
      <xsl:call-template name="cross.compare">
        <xsl:with-param name="a" select="$profile.userlevel"/>
        <xsl:with-param name="b" select="$context/@userlevel"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="userlevel.ok" select="not($context/@userlevel) or not($profile.userlevel) or
                                            $userlevel.content != '' or $context/@userlevel = ''"/>

  <xsl:variable name="vendor.content">
    <xsl:if test="$context/@vendor">
      <xsl:call-template name="cross.compare">
        <xsl:with-param name="a" select="$profile.vendor"/>
        <xsl:with-param name="b" select="$context/@vendor"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="vendor.ok" select="not($context/@vendor) or not($profile.vendor) or
                                         $vendor.content != '' or $context/@vendor = ''"/>

  <xsl:variable name="attribute.content">
    <xsl:if test="$context/@*[local-name()=$profile.attribute]">
      <xsl:call-template name="cross.compare">
        <xsl:with-param name="a" select="$profile.value"/>
        <xsl:with-param name="b" select="$context/@*[local-name()=$profile.attribute]"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="attribute.ok"
                select="not($context/@*[local-name()=$profile.attribute]) or not($profile.value) or
                        $attribute.content != '' or
                        $context/@*[local-name()=$profile.attribute] = '' or not($profile.attribute)"/>

  <!-- Original code:
    <xsl:if test="$arch.ok and $condition.ok and $conformance.ok and $lang.ok and $os.ok
                and $revision.ok and $revisionflag.ok and $role.ok and $security.ok
                and $userlevel.ok and $vendor.ok and $attribute.ok">
    <xsl:copy>
      <xsl:apply-templates select="$context/@*|node()" mode="profile"/>
    </xsl:copy>
  </xsl:if>
  -->
  <xsl:choose>
    <xsl:when test="$arch.ok and $condition.ok and $conformance.ok and $lang.ok and $os.ok
                and $revision.ok and $revisionflag.ok and $role.ok and $security.ok
                and $userlevel.ok and $vendor.ok and $attribute.ok">1</xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="profile.pi">
  <xsl:variable name="os.attr">
         <xsl:call-template name="pi-attribute">
            <xsl:with-param name="pis" select="."/>
            <xsl:with-param name="attribute" select="'os'"/>
         </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="os.content">
         <xsl:if test="$os.attr">
            <xsl:call-template name="cross.compare">
               <xsl:with-param name="a" select="$profile.os"/>
               <xsl:with-param name="b" select="$os.attr"/>
            </xsl:call-template>
         </xsl:if>
  </xsl:variable>
  <xsl:variable name="os.ok" select="not($os.attr) or not($profile.os) or
         $os.content != '' or $os.attr = ''"/>

   <xsl:choose>
     <xsl:when test="$os.ok">1</xsl:when>
     <xsl:otherwise>0</xsl:otherwise>
   </xsl:choose>
</xsl:template>


<xsl:template match="processing-instruction()" mode="profile">
  <xsl:variable name="result">
     <xsl:call-template name="profile.pi"/>
  </xsl:variable>
  <xsl:if test="$result = 1">
     <xsl:copy/>
     <xsl:text>&#10;</xsl:text>
   </xsl:if>
</xsl:template>


<xsl:template match="processing-instruction('provo')" mode="profile">
   <xsl:variable name="result">
      <xsl:call-template name="profile.pi"/>
   </xsl:variable>
   <xsl:variable name="dirname">
      <xsl:call-template name="pi-attribute">
        <xsl:with-param name="pis" select="."/>
        <xsl:with-param name="attribute" select="'dirname'"/>
      </xsl:call-template>
   </xsl:variable>

   <xsl:choose>
      <xsl:when test="$result = 1">
         <xsl:processing-instruction name="{local-name()}">
            <xsl:choose>
               <xsl:when test="$provo.root = ''">
                  <xsl:value-of select="."/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>dirname=</xsl:text>
                  <xsl:value-of select="concat('&quot;', $provo.root, '/', $dirname, '&quot;')"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:processing-instruction>
      </xsl:when>
      <xsl:otherwise/>
   </xsl:choose>
</xsl:template>

</xsl:stylesheet>
