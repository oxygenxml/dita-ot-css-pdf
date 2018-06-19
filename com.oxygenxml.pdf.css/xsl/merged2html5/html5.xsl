<?xml version="1.0" encoding="UTF-8"?><!-- This stylesheet assembles all the basic dita to 
     html transformation, the TOC, index specific 
     transformation and the user extension point.--><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:opentopic="http://www.idiominc.com/opentopic" xmlns:oxy="http://www.oxygenxml.com/extensions/author" xmlns:opentopic-index="http://www.idiominc.com/opentopic/index" xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder" version="2.0" exclude-result-prefixes="#all">

  <!-- DITA OT Basic HTML tranformation. -->
  <xsl:import href="plugin:org.dita.html5:xsl/dita2html5Impl.xsl"/>
  
  <xsl:import href="html5-class-attributes.xsl"/>
  <xsl:import href="html5-other-attributes.xsl"/>
  <xsl:import href="html5-link-attributes.xsl"/>
  <xsl:import href="html5-convert-to-divs.xsl"/>
  <xsl:import href="html5-index.xsl"/>
  <xsl:import href="html5-main.xsl"/>
  <xsl:import href="html5-figures.xsl"/>
  <xsl:import href="html5-footnotes.xsl"/>
    
  <!-- XSLT extension point for the HTML5 DITA processing -->
  

  <!-- XSLT extension point defined from a publishing template file. -->
  <xsl:import xmlns:dita="http://dita-ot.sourceforge.net" href="template:xsl/com.oxygenxml.pdf.css.xsl.merged2html5"/> 
  
  <xsl:output method="xhtml" encoding="UTF-8" indent="no" omit-xml-declaration="yes"/>
  <xsl:param name="figure.title.placement" select="'top'"/>

</xsl:stylesheet>