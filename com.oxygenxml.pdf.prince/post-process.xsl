<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    >
	
    <xsl:output exclude-result-prefixes="oxy opentopic opentopic-index"/>
	
	<xsl:param name="args.input"/>
    <xsl:param name="dita.map.filename.root"/>
    <xsl:param name="chapter.depth">1</xsl:param>
	
	<!--
		
        Create a title page
        
	-->
    <xsl:template match="map">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <oxy:front-page>
                <oxy:front-page-title>
                    <xsl:value-of select="@title"/>
                </oxy:front-page-title>
            </oxy:front-page>
        	
        	<xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
	
	
    <!--
    	
        TOC fixes.
        
    -->
    <!-- Remove the the link text, leave only the navtitle, which has markup. -->
    <xsl:template match="opentopic:map//linktext"/>
    <!-- Move the id from the topicref parent to the navtitle.
        The id is declared again in the topic content below. -->
    <xsl:template match="opentopic:map//topicref/@id"/>
    <xsl:template match="opentopic:map//topicref/@href"/>
    <xsl:template match="opentopic:map//navtitle">
        <xsl:copy>
            <xsl:attribute name="href">
                <xsl:value-of select="../../@first_topic_id"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- Mark the chapters, so their titles can be presented differently in the TOC. -->
    <xsl:template match="*[contains(@class,' map/topicref ') and
        count(ancestor::*[contains(@class,' map/topicref ')]) &lt; $chapter.depth]">
        <xsl:copy>
            <xsl:attribute name="is-chapter">true</xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- Add a reference to the generated index element -->
    <xsl:template match="opentopic:map">
        <xsl:copy>
        	
            <xsl:apply-templates select="@*|node()"/>
        	
            <xsl:variable name="indexElem" select="//opentopic-index:index.groups[1]"/>
            <xsl:if test="$indexElem">
                <xsl:variable name="indexId" select="generate-id($indexElem)"/>
                <topicref is-chapter="true" class="- map/topicref ">
                    <topicmeta class="- map/topicmeta ">
                        <!-- TODO i18n -->
                        <linktext href="#{$indexId}" class="- map/linktext ">Index</linktext>
                    </topicmeta>
                </topicref>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
	
	
    <!--
    	
        Page Breaks at chapter boundaries.
        
    -->
    <xsl:template match="*[contains(@class,' topic/topic ') and
                            count(ancestor::*[contains(@class,' topic/topic ')]) &lt; $chapter.depth]">
        <xsl:copy>
            <xsl:attribute name="is-chapter">true</xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
	
    <!--
    	
        Images.
        
    -->
    <!-- Convert from relative to absolute. -->
    <xsl:template match="*[contains(@class,' topic/image ')]/@href">
        <xsl:if test="not(contains(., '//'))">
        	
            <xsl:message><xsl:value-of select="$dita.map.filename.root"/></xsl:message>
            <xsl:message><xsl:value-of select="$args.input"/></xsl:message>
        	
            <xsl:variable name="map-dir-uri">
                <xsl:value-of select="
                    concat('file:/',
                    translate(substring-before($args.input, concat($dita.map.filename.root, '.ditamap')) , '\', '/'))"/>
            </xsl:variable>
            <xsl:message><xsl:value-of select="$map-dir-uri"/></xsl:message>
            <xsl:attribute name="href">
                <xsl:value-of select="concat($map-dir-uri, '/',.)"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
	
    <!--
    	
        Comments.
        
    -->
    <!-- Transform all the oxygen PI with a comment into comment elements -->
    <xsl:template match="
        processing-instruction('oxy_comment_start') |
        processing-instruction('oxy_delete') |
        processing-instruction('oxy_insert_start')">

        <xsl:variable name="comment-text">
            <xsl:call-template name="get-comment-part">
                <xsl:with-param name="part" select="'comment'"/>
            </xsl:call-template>
        </xsl:variable>
    	
        <xsl:if test="string-length(normalize-space($comment-text)) > 0">
            <xsl:variable name="comment-id"><xsl:number level="any"/></xsl:variable>
            <oxy:comment-anchor id="sc_{$comment-id}" hr_id="{$comment-id}"/>
            <oxy:comment href="#sc_{$comment-id}" hr_id="{$comment-id}">
            	<oxy:comment-author>
                    <xsl:call-template name="get-comment-part">
                        <xsl:with-param name="part" select="'author'"/>
                    </xsl:call-template>
                </oxy:comment-author>
            	
                <oxy:comment-text>
                    <xsl:value-of select="$comment-text" disable-output-escaping="yes"/>
                </oxy:comment-text>
            	
                <oxy:comment-date >
                    <xsl:variable name="ts">
                        <xsl:call-template name="get-comment-part">
                            <xsl:with-param name="part" select="'timestamp'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="substring($ts,1,4)"/>/<xsl:value-of select="substring($ts,5,2)"/>/<xsl:value-of select="substring($ts,7,2)"/>
                </oxy:comment-date>
            </oxy:comment>
        </xsl:if>
    </xsl:template>
	
    <!-- Gets a part from the comment PI. -->
    <xsl:template name="get-comment-part">
        <xsl:param name="part"/>
        <xsl:variable name="data" select="."/>
        <xsl:variable name="after" select="
            substring-after($data,
                            concat($part, '=&quot;'))"/>
        <xsl:variable name="before" select="
            substring-before($after,
                            '&quot;')"/>
    	
        <xsl:value-of select="$before" />
    </xsl:template>
	
	
    <!--
    	
    	
        Index fixes.
		
        Adds an id for each indexterm.
        In the group of indexterms make sure there are pointers back to the indexterms from the content.
        Prince needs this in order to create the index links.
		
    -->
	
    <!-- For each refID in the content, make sure there is an @id attribute for it. -->
    <xsl:template match="*[contains(@class,' topic/topic ')]//opentopic-index:refID">
        <xsl:copy>
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id(.)"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="opentopic-index:index.groups//opentopic-index:refID[@value]">
        <xsl:copy>
        	<xsl:apply-templates select="node()|@*"/>
			
            <xsl:variable name="for-value" select="@value"/>
            <xsl:for-each select="//*[contains(@class,' topic/topic ')]//opentopic-index:refID[@value = $for-value]">
                <oxy:index-link href="#{generate-id(.)}">
                    [<xsl:value-of select="generate-id(.)"/>]
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
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
	
	
    <!--
    	
        Default copy template.
		
    -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
	
</xsl:stylesheet>