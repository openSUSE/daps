<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- 
  * Purpose:
  Template for generating indexterm ranges automatically.     
  You write, for example:
    
  <chapter>
     <title>...</title>
     <indexterm id="idx.foo" role="range">
        <primary>foo</primary>
     </indexterm>

     <sect1> ... </sect1>
     <sect1> ... </sect1>

  </chapter>
  
  
  The stylesheet sets indexterm with class="startofrange" and class="endofrange".
  It takes into account the structure of your document and adds the correct
  indexterm to the last element.
  
  Best applied after profiling.
    
-->
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="screen literallayout programlisting"/>

    <xsl:param name="index.prefix">idx.</xsl:param>
    <xsl:key name="indexterm.with.class" match="indexterm[@class]" use="indexterm"/>

    <!-- Copy all non-element nodes -->
    <xsl:template match="@*|text()|comment()|processing-instruction()" mode="indexrange">
        <xsl:copy/>
    </xsl:template>

    <xsl:template match="*" mode="indexrange">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="indexrange"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/">
        <xsl:apply-templates mode="indexrange"/>
    </xsl:template>


    <!--  -->
    <xsl:template match="indexterm[@role='range']" mode="startofrange">
        <xsl:param name="node" select="."/>

        <xsl:copy>
            <xsl:attribute name="class">startofrange</xsl:attribute>
            <xsl:attribute name="id">
                <xsl:choose>
                    <xsl:when test="@id">
                        <xsl:value-of select="@id"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$index.prefix"/>
                        <xsl:value-of select="generate-id($node)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!--<xsl:if test="@significance='normal'">
                <xsl:attribute name="significance">preferred</xsl:attribute>
            </xsl:if>-->
            <xsl:apply-templates mode="indexrange"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*|text()|processing-instruction()|comment()" mode="startofrange"/>
    
    <!--  -->
    <xsl:template match="title|subtitle|titleabbrev" mode="title">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="indexrange"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="processing-instruction()" mode="title">
        <xsl:processing-instruction name="{name(.)}">
            <xsl:value-of select="."/>
        </xsl:processing-instruction>
    </xsl:template>
    
    <xsl:template match="comment()" mode="title">
        <xsl:comment>
            <xsl:value-of select="."/>
        </xsl:comment>
    </xsl:template>
    
    <xsl:template match="*|text()" mode="title"/>

    <!--  -->
    <xsl:template match="article|appendix
                         |bibliography
                         |chapter
                         |preface
                         |glossary
                         |reference"
      mode="indexrange">
        <xsl:param name="indexrange" select="indexterm[@role='range']"/>
        <xsl:variable name="lastnode" select="*[last()]"/>
        
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!--<xsl:copy-of select="processing-instruction()"/>-->
            <xsl:apply-templates mode="title"/>
            <xsl:apply-templates mode="startofrange"/>


            <!-- Check for last node -->
            <xsl:choose>
                <xsl:when test="$lastnode/self::sect1 or 
                                $lastnode/self::refentry">                    
                    <xsl:apply-templates mode="indexrange">
                        <xsl:with-param name="indexrange" select="$indexrange"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!--  -->
                <xsl:otherwise>
                    <xsl:apply-templates mode="indexrange">
                        <xsl:with-param name="indexrange" select="$indexrange"/>
                    </xsl:apply-templates>

                    <xsl:for-each select="$indexrange">
                        <xsl:choose>
                            <xsl:when test="@id">
                                <indexterm class="endofrange" startref="{@id}"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <indexterm class="endofrange"
                                    startref="{concat($index.prefix,generate-id(.))}"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="sect1|sect2|sect3|sect4" mode="indexrange">
        <xsl:param name="indexrange" select="__DUMMY_NODE__"/>
        <xsl:variable name="thisrange" select="indexterm[@role='range']"/>
        <xsl:variable name="lastnode" select="*[last()]"/>
        <xsl:variable name="sibl" select="following-sibling::*"/>

       <!-- <xsl:message> sect1: count=<xsl:value-of select="count($indexrange)"/> siblings =
                <xsl:value-of select="count($sibl)"/>
                </xsl:message>-->
        
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="title"/>
            <xsl:apply-templates mode="startofrange"/>

            <xsl:choose>
                <xsl:when
                    test="$lastnode/self::sect2 or 
                          $lastnode/self::sect3 or
                          $lastnode/self::sect4 or
                          $lastnode/self::section or
                          $lastnode/self::simplesect or
                          $lastnode/self::refentry">
                    <xsl:apply-templates mode="indexrange">
                        <xsl:with-param name="indexrange" select="$indexrange|$thisrange"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!--  -->
                <xsl:otherwise>
                    <xsl:apply-templates mode="indexrange">
                        <xsl:with-param name="indexrange" select="indexterm[@role='range']"/>
                    </xsl:apply-templates>

                    <xsl:if test="not($sibl)">
                        
                        <xsl:for-each select="$indexrange">
                            <indexterm class="endofrange">
                                <!--<xsl:if test="@significance='preferred'"></xsl:if>-->
                                <xsl:choose>
                                    <xsl:when test="current()/@id">
                                        <xsl:attribute name="startref">
                                            <xsl:value-of select="@id"/>
                                        </xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="startref">
                                            <xsl:value-of
                                                select="concat($index.prefix, generate-id())"/>
                                        </xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </indexterm>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="indexterm" mode="indexrange">
        <indexterm>
          <!-- Copy every attribute except @significance -->
          <xsl:copy-of select="@*[not(local-name(.)='significance')]"/>
          <xsl:if test="@significance = 'preferred'">
              <xsl:copy-of select="@significance"/>
          </xsl:if>          
          <xsl:apply-templates mode="indexrange"/>
        </indexterm>
    </xsl:template>

    <xsl:template match="indexterm[@role='range']" mode="indexrange"/>

    <xsl:template match="title|subtitle|titleabbrev" mode="indexrange"/>

    <xsl:template match="processing-instruction()|comment()" mode="indexrange"/>
    
</xsl:stylesheet>
