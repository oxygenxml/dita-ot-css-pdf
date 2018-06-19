<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- Create anchors for the indexterms from the content -->
    <xsl:template match="*[contains(@class, ' topic/title ') and following-sibling::*[contains(@class, ' topic/prolog ')]]">
        <xsl:apply-templates select="following-sibling::*[contains(@class, ' topic/prolog ')]" mode="create-anchor"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/prolog ')]" mode="create-anchor">
        <xsl:for-each select="*[contains(@class, ' topic/metadata ')]//*[contains(@class, ' topic/keywords ')]//opentopic-index:index.entry//opentopic-index:refID">
            <div class=" index/anchor anchor" id="{@id}"/>
        </xsl:for-each>
    </xsl:template>
        
    
</xsl:stylesheet>