<?xml version="1.0" encoding="UTF-8"?>
<!-- 

  This stylesheet changes the figures layout.

-->
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:opentopic="http://www.idiominc.com/opentopic"
  xmlns:oxy="http://www.oxygenxml.com/extensions/author"
  xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
  xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
  xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
  
  exclude-result-prefixes="#all">

  
  <!-- =========== FIGURE =========== -->
  <!-- Overriding org.dita.html5/xsl/topic.xsl -->
  <xsl:template match="*[contains(@class, ' topic/fig ')]" name="topic.fig">
    <xsl:variable name="default-fig-class">
      <xsl:apply-templates select="." mode="dita2html:get-default-fig-class"/>
    </xsl:variable>
    <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
    <figure>
      <xsl:if test="$default-fig-class != ''">
        <xsl:attribute name="class" select="$default-fig-class"/>
      </xsl:if>
      <xsl:call-template name="commonattributes">
        <xsl:with-param name="default-output-class" select="$default-fig-class"/>
      </xsl:call-template>
      <xsl:call-template name="setscale"/>
      <xsl:call-template name="setidaname"/>
      
      <!-- DCP-78 Move the figure caption depending on a parameter. -->
      <xsl:choose>
        <xsl:when test="$figure.title.placement = 'top'">
          <xsl:call-template name="place-fig-lbl"/>
          <xsl:apply-templates select="node() except *[contains(@class, ' topic/title ') or contains(@class, ' topic/desc ')]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="node() except *[contains(@class, ' topic/title ') or contains(@class, ' topic/desc ')]"/>
          <xsl:call-template name="place-fig-lbl"/>
        </xsl:otherwise>
      </xsl:choose>
      
    </figure>
    <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
  </xsl:template>
  
</xsl:stylesheet>