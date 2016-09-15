<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:ImageInfo="java:ImageInfo" exclude-result-prefixes="#all">
    
    <!-- 
        
        Mark the chapters, so their titles can be presented differently in the TOC. 
    
    -->
    <xsl:template
        match="opentopic:map//*[contains(@class,' bookmap/chapter ')] |
               opentopic:map/*[contains(@class,' bookmap/part ')]/*[contains(@class,' map/topicref ')]   |
               opentopic:map/*[contains(@class,' map/topicref ')]">
        <xsl:copy>
            <xsl:attribute name="is-chapter">true</xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- 
        
        Make the bookmap parts transparent to the transformation, it makes the chapter 
        marking cumbersom (see the template below). 
    
    -->
    <xsl:template match="//opentopic:map/*[contains(@class, ' bookmap/part ')]" priority="200">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <!-- 
        
        Page Breaks at chapter boundaries, in the content. 
    
    -->
    <xsl:template
        match="
        *[contains(@class,' topic/topic ')  and
        count(ancestor::*[contains(@class,' topic/topic ')]) &lt; 1]">
        <xsl:copy>
            <xsl:attribute name="break-before">true</xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>