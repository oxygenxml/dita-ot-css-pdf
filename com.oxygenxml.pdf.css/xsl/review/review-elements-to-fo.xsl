<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs saxon oxy"
    version="2.0"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author">
    <xsl:include href="review-utils.xsl"/>
    <xsl:param name="show.changes.and.comments" select="'no'"/>
    
    <xsl:template match="oxy:*">
        <!-- Usually ignore contents -->
    </xsl:template>
    
    <xsl:template match="oxy:oxy-range-end">
        <xsl:call-template name="generateFootnote">
            <xsl:with-param name="elem" select="oxy:findHighlightInfoElement(.)"/>
            <xsl:with-param name="color" select="'black'"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- INSERT CHANGE, USE UNDERLINE -->
    <xsl:template match="oxy:oxy-insert-hl">
        <fo:inline color="blue">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- DELETE CHANGE, USE STRIKEOUT -->
    <xsl:template match="oxy:oxy-delete-hl">
        <fo:inline color="red" text-decoration="line-through">
            <xsl:apply-templates/>
        </fo:inline>    
    </xsl:template>
    
    <!-- COLOR HIGHLIGHT, USE PROPER BG COLOR -->
    <xsl:template match="oxy:oxy-color-hl" >
        <!--  Move the color to a style attribute-->
        <fo:inline background-color="{@color}">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- COMMENT CHANGE -->
    <xsl:template match="oxy:oxy-comment-hl">
        <fo:inline background-color="yellow">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <xsl:template name="generateFootnote">
        <xsl:param name="elem"/>
        <xsl:param name="color"/>
        <xsl:variable name="number" select="$elem/@hr_id"/>
        <xsl:variable name="commentContent">
            <xsl:apply-templates mode="getCommentContent" select="$elem">
                <xsl:with-param name="number" select="$number"/>
            </xsl:apply-templates>
        </xsl:variable>
        
        <xsl:if test="$commentContent != ''">
            <xsl:variable name="fnid" select="generate-id($elem)"/>
            <fo:basic-link internal-destination="{$fnid}">
                <fo:footnote start-indent="0" font-style="normal"
                    font-size="14" font-weight="100"
                    text-decoration="none">
                    <fo:inline baseline-shift="super" font-size="75%" color="{$color}">[<xsl:value-of select="$number"/>]</fo:inline>
                    <fo:footnote-body>   
                        <fo:block color="{$color}" id="{$fnid}">     
                            <xsl:copy-of select="$commentContent"/>                                          
                        </fo:block>
                    </fo:footnote-body>
                </fo:footnote>
            </fo:basic-link>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template mode="getCommentContent" match="*">
        <xsl:param name="number"/>
        <xsl:param name="indent" select="0"/>
        <fo:block>
            <xsl:choose>
                <!-- Nested replies, indent to the left so that they appear like a conversation..-->
                <xsl:when test="$indent = 1">
                    <xsl:attribute name="margin-left" select="20"/>
                </xsl:when>
                <xsl:when test="$indent > 1">
                    <xsl:attribute name="margin-left" select="$indent * 10"/>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="$number">
                <fo:inline baseline-shift="super" font-size="75%">
                    <xsl:value-of select="$number"/>
                </fo:inline>
            </xsl:if>
            <!-- Comment. -->
            <xsl:choose>
                <xsl:when test="local-name() = 'oxy-attributes'">
                    <!-- <oxy:oxy-attributes xmlns:oxy="http://www.oxygenxml.com/extensions/author" href="#sc_1" hr_id="1">
                        <oxy:oxy-attribute-change name="id" type="inserted">
                        <oxy:oxy-author>radu_coravu</oxy:oxy-author>
                        <oxy:oxy-current-value unknown="true"/>
                        <oxy:oxy-date>2016/08/03</oxy:oxy-date>
                        <oxy:oxy-hour>14:27:26</oxy:oxy-hour>
                        <oxy:oxy-tz>+03:00</oxy:oxy-tz>
                        </oxy:oxy-attribute-change>
                        </oxy:oxy-attributes> -->
                    <xsl:for-each select="oxy:oxy-attribute-change">
                        <!-- Take each of the attribute changes (are separated with spaces.) -->
                        <xsl:value-of select="oxy:oxy-author"/>:&#160; <xsl:value-of select="@type"/> attr "<xsl:value-of select="@name"/>"
                        <xsl:if test="oxy:oxy-old-value[@unknown!='true']">old value=</xsl:if><xsl:value-of select="oxy:oxy-old-value"/>&#160;
                        <xsl:if test="oxy:oxy-current-value[@unknown!='true']">current value=</xsl:if><xsl:value-of select="oxy:oxy-current-value"/>
                        &#160;
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="comment-text" select="oxy:oxy-comment-text"/>
                    <!-- Author -->
                    <xsl:variable name="author" select="oxy:oxy-author"/>
                    <xsl:if test="string-length($author) > 0">
                        <xsl:value-of select="$author"/>:&#160;
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="string-length($comment-text) > 0">
                            <xsl:value-of select="$comment-text" disable-output-escaping="yes"/>
                        </xsl:when>
                        <xsl:when test="starts-with(local-name(), 'oxy-insert')">
                            [Insertion]
                        </xsl:when>
                        <xsl:when test="starts-with(local-name(), 'oxy-delete')">
                            [Deletion]
                        </xsl:when>
                        <xsl:otherwise>
                            [Modification]
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <!-- RECURSE TO GATHER REPLIES... -->
            <xsl:variable name="gathered">
                <xsl:apply-templates mode="getCommentContent" select="oxy:oxy-comment">
                    <xsl:with-param name="indent" select="$indent + 1"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:if test="$gathered">
                <fo:block>
                    <xsl:copy-of select="$gathered"/>
                </fo:block>
            </xsl:if>
        </fo:block>
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