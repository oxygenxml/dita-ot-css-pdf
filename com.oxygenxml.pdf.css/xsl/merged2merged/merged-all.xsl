<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:ImageInfo="java:ImageInfo" exclude-result-prefixes="#all">

    <xsl:param name="args.draft" select="'no'"/>
    <xsl:param name="input.dir.url"/>
    <xsl:param name="transtype" />
    <xsl:param name="figure.title.placement" select="'top'"/>
     
    <xsl:include href="../review/review-pis-to-elements.xsl"/>    
    <xsl:include href="merged-filtering.xsl"/>    
    <xsl:include href="merged-toc.xsl"/>
    <xsl:include href="merged-create-title-page.xsl"/>
    <xsl:include href="merged-chapters.xsl"/>
    <xsl:include href="merged-frontmatter-backmatter.xsl"/>
    <xsl:include href="merged-images.xsl"/>    
    <xsl:include href="merged-draft-comments.xsl"/>    
    <xsl:include href="merged-index.xsl"/>    
    <xsl:include href="merged-tables.xsl"/>
    <xsl:include href="merged-links.xsl"/>
    <xsl:include href="merged-whitespaces.xsl"/>
    <xsl:include href="merged-topics.xsl"/>
    <xsl:include href="merged-figures.xsl"/>
    
    <xsl:include href="merged-flagging.xsl"/>
    <xsl:include href="merged-placeholders.xsl"/>
</xsl:stylesheet>
