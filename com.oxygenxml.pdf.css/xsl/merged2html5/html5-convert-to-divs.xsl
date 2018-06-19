<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Converts the DIVS the foreign elements, like map, index.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
   
  <!--
    All the elements from other namespaces should have their contents 
    transformed in a tree of 'div' elements. They already have a @class
    attribute added by the merged map post-processing step.
  -->
    <xsl:template match="opentopic-index:* | opentopic:* | oxy:* | ot-placeholder:* ">
        <xsl:apply-templates select="." mode="div-it"/>
    </xsl:template>
    
    <!-- Found a topic inside, go back to the default transformation -->
    <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="div-it">
        <xsl:apply-templates select="." />
    </xsl:template>

    <!-- Indexterms from the topic content should become spans and be 
         styled as transparent from the CSS. In this way they do not break the lines. -->
    <xsl:template match="*[ancestor-or-self::*[contains(@class, ' index/entry ')]][ancestor::*[contains(@class, ' topic/topic ')]]" mode="div-it">   
        <span>
            <xsl:call-template name="div-it-element-content"/>
        </span>
    </xsl:template>
  
    <xsl:template match="*" mode="div-it">
        <div>
            <xsl:call-template name="div-it-element-content"/>
        </div>
    </xsl:template>

  	<!-- Generates attributes and children for a foreign element -->
    <xsl:template name="div-it-element-content">
      <xsl:apply-templates select="@* except @class" mode="div-it"/>
      <xsl:call-template name="commonattributes"/>
      <xsl:apply-templates select="node()" mode="div-it"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="div-it">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="@*" mode="div-it">
        <xsl:copy/>  
    </xsl:template>
    
    <xsl:template match="@xtrf" mode="div-it" priority="2"/>
    <xsl:template match="@xtrc" mode="div-it" priority="2"/>
    
    
</xsl:stylesheet>