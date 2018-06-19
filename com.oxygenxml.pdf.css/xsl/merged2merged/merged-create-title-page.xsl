<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:ImageInfo="java:ImageInfo" exclude-result-prefixes="#all">
    
    <!-- This is moved in the root. -->
    <xsl:template match="opentopic:map/*[contains(@class, ' map/topicmeta ')]"/>
    
    <!--
		
        Create a title page
        
	-->
    <xsl:template match="*[contains(@class, ' map/map ')]" priority="2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>

            <oxy:front-page class=" front-page/front-page ">
                <!-- Move also metadata, so it can be used in the string-sets starting with the front page. -->
                <xsl:copy-of select="opentopic:map/*[contains(@class, ' map/topicmeta ')]"/>
            
                <oxy:front-page-title class=" front-page/front-page-title ">
                    <xsl:choose>
                        <xsl:when test="@title">
                            <xsl:value-of select="@title"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates
                                select="opentopic:map/*[contains(@class, ' topic/title ')]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </oxy:front-page-title>
            </oxy:front-page>

            <!-- Bookmap: Expand frontmatter -->
            <xsl:variable name="frontmatter" select="//*[contains(@class, ' bookmap/frontmatter ')]"/>
            <xsl:if test="$frontmatter">
                <oxy:front-matter class="{$frontmatter/@class}">
                    <xsl:apply-templates select="$frontmatter" mode="expand"/>
                </oxy:front-matter>
            </xsl:if>


  			<!-- Maybe it has Oxygen attribute changes processing instructions before it. Move them into the root. --> 
            <xsl:call-template name="add-review-pis-for-root"/>

            <xsl:for-each select="node()">
                <xsl:choose>
                    <xsl:when test="self::opentopic:map">
                        <!-- Move the topics marked with "before-toc" before this element. -->
                        <xsl:apply-templates select="following-sibling::*[contains(@outputclass,'before-toc')] | 
                                                     following-sibling::*[contains(key('map-id', concat('#', @id))/@outputclass, 'before-toc')]"/>
                        <xsl:apply-templates select="."/>
                    </xsl:when>
                    <xsl:when test="self::*[contains(@outputclass,'before-toc')] or self::*[contains(key('map-id', concat('#', @id))/@outputclass, 'before-toc')]">
                        <!-- Ignore, was handled before -->
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Default processing -->
                        <xsl:apply-templates select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <!-- Bookmap: Expand backmatter -->
            <xsl:variable name="backmatter" select="//*[contains(@class, ' bookmap/backmatter ')]"/>
            <xsl:if test="$backmatter">
                <oxy:back-matter class="{$backmatter/@class}">
                    <xsl:apply-templates select="$backmatter" mode="expand"/>
                </oxy:back-matter>
            </xsl:if>

        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>