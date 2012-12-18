<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY para.parent "parent::appendix | parent::chapter | parent::bibliography |
                   parent::glossary | parent::preface | parent::reference |
                   parent::sect1 | parent::sect2 | parent::sect3 | parent::sect4 | parent::sect5 |
                   parent::refsect1 | parent::refsect2 | parent::refsect3 |
                   parent::listitem">
]>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common"
                xmlns:exsl="http://exslt.org/functions"
                xmlns:saxon="http://icl.com/saxon"
                xmlns:suse="urn:x-suse:xmlns:exsl:functions"
                xmlns:vset="http:/www.ora.com/XSLTCookbook/namespaces/vset"
                extension-element-prefixes="exsl exslt"
                exclude-result-prefixes="suse saxon exsl exslt vset">

<xsl:include href="../common/vset.ops.xsl"/>

<!-- Should I determine and handle paras that needs to be markuped? -->
<xsl:param name="process.para" select="1"/>


<!--
    *** Explanation ***

    paras can have @arch attributes. Depending what your profile.arch attribut is
    it might be possible to copy the @arch attribute or to omit it.

    Therefor we have two sets:

    F = set from profile.arch. It contains all architectures that you are interested in
    p = set from @arch of the current para

    You need to determine if F is an equal subset of p. In this stylesheet it is done
    by:  bg.diff.count = F \ (F intersection with p)

    if bg.diff.count == 0:  omit the @arch
    if bg.diff.count != 0:  create a sorted, modified list of architectures for @arch


    Example 1:
    F  = {x86, amd64, em64t}
    p1 = {x86}

    F intersection with p = {x86, amd64, em64t} intersection with {x86}  = {x86}
    F \ {x86} = {amd64, em64t} => count{amd64, em64t} > 0 => use intersection


    Example 2:
    F  = {x86, amd64, em64t}
    p2 = {x86, amd64, em64t, s390}

    F intersection with p = {x86, amd64, em64t} intersection with {x86, amd64, em64t, s390}  = {x86, amd64, em64t}
    F \ {x86, amd64, em64t} = {} => count{} = 0 => don't use intersection


    Procedure:
    1. Check if para has an @arch attribute: false -> apply default
    2. Check, if the switch $process.para = 0: true -> apply default
    3. Check, if para needs to be profiled: true -> Do our special handling
    4. Create an RTF (result tree fragment) of the string from @arch in rtf.arch.
       This means, you have in rtf.arch now e.g. <token><attr>x86</attr></token>
    4. Create an RTF of the string from $profile.arch in rtf.profile.arch.
    5. Convert the two RTFs in real node sets with the help from exslt:node-set
       and save it into node.arch.attr and node.profile.arch.attr
    6. Calculate the intersection between $node.profile.arch.attr and node.arch.attr
    7. Calculate the difference between $node.profile.arch.attr and $nodes.intersection
       (from step 6)
    8. Count the nodes from step 7, save it into bg.diff.count
    9. Check if bg.diff.count == 0:
       True  -> Omit the @arch attribute
       False -> Copy the intersection into @arch,

-->
<!-- ************************************************** -->
<xsl:template match="para[&para.parent;]" mode="profile">
  <xsl:variable name="doprofile">
    <xsl:call-template name="check.profiling">
      <xsl:with-param name="context" select="self::para"/>
    </xsl:call-template>
  </xsl:variable>


  <xsl:choose>
    <xsl:when test="not(@arch)">
      <!-- paras that don't have @arch attributes needs not to be profiled -->
      <xsl:apply-imports/>
    </xsl:when>
    <xsl:when test="$process.para = 0">
      <!-- If we don't want to process the paras in this special way,
           do the use the default method
      -->
      <xsl:apply-imports/>
    </xsl:when>
    <xsl:when test="$doprofile = 1">
      <!-- -->
      <xsl:variable name="rtf.arch">
        <xsl:call-template name="createnodes">
          <xsl:with-param name="strings" select="@arch"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="rtf.profile.arch">
        <xsl:call-template name="createnodes">
          <xsl:with-param name="strings" select="$profile.arch"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="node.arch.attr" select="exslt:node-set($rtf.arch)/*/attr"/>
      <xsl:variable name="node.profile.arch.attr"  select="exslt:node-set($rtf.profile.arch)/*/attr"/>

      <xsl:variable name="nodes.intersection">
         <xsl:call-template name="vset:intersection">
            <xsl:with-param name="nodes1" select="$node.profile.arch.attr"/>
            <xsl:with-param name="nodes2" select="$node.arch.attr"/>
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="bg.diff">
         <xsl:call-template name="vset:difference">
            <xsl:with-param name="nodes1" select="exslt:node-set($node.profile.arch.attr)"/>
            <xsl:with-param name="nodes2" select="exslt:node-set($nodes.intersection)"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="bg.diff.count" select="count(exslt:node-set($bg.diff)/*)"/>

      <xsl:choose>
       <xsl:when test="$bg.diff.count">
         <para>
           <xsl:copy-of select="@*[local-name() != 'arch']"/>
           <xsl:attribute name="arch">
              <xsl:for-each select="exslt:node-set($nodes.intersection)/*">
                <xsl:sort select="self::attr" />
                <xsl:value-of select="."/>
                <xsl:if test="position()!=last()">
                  <xsl:value-of select="$profile.separator"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>
            <xsl:apply-templates mode="profile"/>
         </para>
         <xsl:text>&#10;</xsl:text>
       </xsl:when>
       <xsl:otherwise>
         <para>
           <xsl:apply-templates select="node()[not(@*)]" mode="profile"/>
         </para>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/><!--  $process.para=0 -->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="createnodes">
   <xsl:param name="strings" select="''"/>
   <xsl:param name="sep" select="$profile.separator" />

   <xsl:choose>
      <xsl:when test="$strings">
         <tokens>
            <xsl:call-template name="split.string">
               <xsl:with-param name="strings" select="$strings"/>
               <xsl:with-param name="sep" select="$sep"/>
            </xsl:call-template>
         </tokens>
      </xsl:when>
   </xsl:choose>
</xsl:template>

<xsl:template name="split.string">
   <xsl:param name="strings" select="''"/>
   <xsl:param name="sep" select="$profile.separator" />

   <xsl:variable name="head" select="substring-before(concat($strings, $sep), $sep)"/>
   <xsl:variable name="tail" select="substring-after($strings, $sep)"/>

   <xsl:if test="$head">
     <attr><xsl:value-of select="$head"/></attr>
     <xsl:call-template name="split.string">
       <xsl:with-param name="strings" select="$tail"/>
     </xsl:call-template>
   </xsl:if>
</xsl:template>


</xsl:stylesheet>
