<?xml version="1.0" encoding="UTF-8"?>
<!-- 
	Process the links references and IDs.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- Copied from: org.dita.html5/xsl/topic.xsl -->
    <!-- Leave the ID elements as they are, they were already resolved in the merged map. -->
    <xsl:template name="setidattr">
      <xsl:param name="idvalue"/>
      <xsl:attribute name="id" select="$idvalue"/>
    </xsl:template>        
    
    <!-- Copied from: org.dita.html5/xsl/topic.xsl -->
    <!-- Leave the @href attributes as they are, they were already resolved in the merged map (the dita to dita links).
         Only the external links should generate the text from the href.  
    -->
    <xsl:template name="href">
      <xsl:choose>
        <xsl:when test="(empty(@format) and @scope = 'external') or (@format and not(@format = 'dita'))">
          <xsl:value-of select="@href"/>
        </xsl:when>
      </xsl:choose>
    </xsl:template>
    
    
    <!--main template for setting up all links after the body - applied to the related-links container-->
  <xsl:template match="*[contains(@class, ' topic/related-links ')]" name="topic.related-links">
    <div class="wh_related_links">
      <xsl:next-match/>
    </div>
  </xsl:template>
</xsl:stylesheet>