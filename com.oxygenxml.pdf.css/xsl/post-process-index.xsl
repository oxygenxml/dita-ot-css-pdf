<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:ImageInfo="java:ImageInfo" exclude-result-prefixes="#all">
    <!--
    	
    	
        Index fixes.
		
        Adds an id for each indexterm.
        In the group of indexterms make sure there are pointers back to the indexterms from the content.
        Prince needs this in order to create the index links.
		
    -->
    

    <!-- For each refID in the content, make sure there is an @id attribute for it. -->
    <xsl:template match="*[contains(@class, ' topic/topic ')]//opentopic-index:refID">
        <xsl:copy>
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id(.)"/>
            </xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="opentopic-index:index.groups//opentopic-index:refID[@value]">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>

            <xsl:variable name="for-value" select="@value"/>
            <xsl:for-each
                select="//*[contains(@class, ' topic/topic ')]//opentopic-index:refID[@value = $for-value]">
                <oxy:index-link href="#{generate-id(.)}"> [<xsl:value-of select="generate-id(.)"/>]
                </oxy:index-link>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <!-- Put an id on the index element, this way we can linked it from the table of contents. -->
    <xsl:template match="opentopic-index:index.groups">
        <xsl:copy>
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id(.)"/>
            </xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>