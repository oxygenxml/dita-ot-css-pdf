<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
    exclude-result-prefixes="#all">
    
    <!-- 
      Add class attribute to all placeholders.
     -->
    <xsl:template match="ot-placeholder:*">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:call-template name="generate-placeholder-element-class"/>
        
        <xsl:apply-templates select="node()"/>
      </xsl:copy>
    </xsl:template>
    
    

    <!-- 
        Adds a class attribute to all the placeholder elements. 
     -->
    <xsl:template name="generate-placeholder-element-class">
        <xsl:variable name="local" select="lower-case(local-name())"/>
        <xsl:attribute name="class">
              <xsl:value-of select="concat(' placeholder/', $local ,' ')"/>
        </xsl:attribute>        
    </xsl:template>    
    
</xsl:stylesheet>
    