<?xml version="1.0" encoding="UTF-8"?>
<!-- 

  This stylesheet changes the default processing of the footnotes.
  For the PDF output they should not generate "a" links, but instead be a simple
  div that is floated as "footnote".

-->
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:opentopic="http://www.idiominc.com/opentopic"
  xmlns:oxy="http://www.oxygenxml.com/extensions/author"
  xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
  xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
  xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
  
  exclude-result-prefixes="#all">
  
  <!-- 
    Leave the footnote as a div, in the original context.
    In this way it can be styled with float: footnote.
  --> 
  <xsl:template match="*[contains(@class, ' topic/fn ')]">
    <span>
      <xsl:call-template name="commonattributes"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
    
</xsl:stylesheet>