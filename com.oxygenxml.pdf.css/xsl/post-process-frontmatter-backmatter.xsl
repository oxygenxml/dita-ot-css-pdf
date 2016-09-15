<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:ImageInfo="java:ImageInfo" exclude-result-prefixes="#all">
    <!-- 
    
        Bookmap: Frontmatter and Backmatter
    
    
    -->
    <xsl:key name="ids_in_frontmatter_backmatter"
        match="
            //*[contains(@class, ' bookmap/frontmatter ')]//*[contains(@class, ' map/topicref ')] |
            //*[contains(@class, ' bookmap/backmatter ')]//*[contains(@class, ' map/topicref ')]
            "
        use="@id"/>
    <!-- Remove the frontmatter/backmatter from the TOC -->
    <xsl:template match="opentopic:map/*[contains(@class, ' bookmap/frontmatter ')]" priority="100"/>
    <xsl:template match="opentopic:map/*[contains(@class, ' bookmap/backmatter ')]" priority="100"/>
    <!-- Remove the frontmatter/backmatter referred topics from the content. -->
    <xsl:template
        match="*[contains(@class, ' topic/topic ')][@id][key('ids_in_frontmatter_backmatter', @id)]"
        priority="100"/>
    <!-- Expand the topicrefs from the frontmatter/backmatter -->    
    <xsl:template match="*[contains(@class, ' map/topicref ')][@href]" mode="expand">
        <xsl:variable name="href" select="substring-after(@href, '#')"/>
        <xsl:copy-of select="//*[contains(@class, 'topic/topic ')][@id = $href]"/>
    </xsl:template>
    <xsl:template match="*|@*" mode="expand" >
        <xsl:apply-templates mode="expand"/>
    </xsl:template>
    <xsl:template match="text()" mode="expand" priority="200"/>
</xsl:stylesheet>