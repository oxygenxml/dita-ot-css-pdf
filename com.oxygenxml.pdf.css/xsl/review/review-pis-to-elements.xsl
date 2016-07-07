<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2016 Syncro Soft SRL, Romania.  All rights reserved.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all">

    <xsl:param name="show.changes.and.comments" select="'no'"/>
    
    <xsl:variable name="cmid2nr">
        <xsl:if test="string($show.changes.and.comments) = 'yes'">
            <xsl:for-each
                select="
                //(
                processing-instruction('oxy_attributes') |
                processing-instruction('oxy_comment_start') |
                processing-instruction('oxy_delete') |
                processing-instruction('oxy_insert_start') |
                processing-instruction('oxy_custom_start'))">
                <mapping id="{generate-id()}" nr="{position()}"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:variable>
    
    
    <!--
    	
        Comments.
        
    -->
    
    
    <!-- Transform all the oxygen PI with a comment into comment elements -->
    <xsl:template
        match="
        processing-instruction('oxy_attributes') |
        processing-instruction('oxy_comment_start') |
        processing-instruction('oxy_delete') |
        processing-instruction('oxy_insert_start')">
        
        
        <xsl:if test="$show.changes.and.comments = 'yes'">
            <xsl:variable name="id" select="generate-id()"/>
            <xsl:variable name="comment-nr" select="$cmid2nr//mapping[@id = $id]/@nr"/>
            
            
            <!-- This anchor will remain in the main flow. -->
            <oxy:oxy-range-start id="sc_{$comment-nr}" hr_id="{$comment-nr}"/>
            
            
            
            <!-- Put the deleted content in the output -->
            <xsl:if test="name() = 'oxy_delete'">
                <oxy:oxy-delete-hl>
                    <xsl:value-of disable-output-escaping="yes">
                        <xsl:call-template name="get-pi-part">
                            <xsl:with-param name="part" select="'content'"/>
                        </xsl:call-template>
                    </xsl:value-of>
                </oxy:oxy-delete-hl>
                <oxy:oxy-range-end hr_id="{$comment-nr}"/>
            </xsl:if>
            
            
            <xsl:if test="name() = 'oxy_attributes'">
                <oxy:oxy-range-end hr_id="{$comment-nr}"/>
            </xsl:if>
            
            <!-- Map the PI to an XML element name, so it can be styled from the CSS. -->
            <xsl:variable name="elname" as="xs:string">
                <xsl:choose>
                    <xsl:when test="ends-with(name(), '_start')">
                        <xsl:value-of select="substring-before(name(), '_start')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="name()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <!-- The bubble that is be placed on the side of the page -->
            <xsl:element name="oxy:{translate($elname,'_','-')}"
                namespace="http://www.oxygenxml.com/extensions/author">
                <xsl:attribute name="href" select="concat('#sc_', $comment-nr)"/>
                <xsl:attribute name="hr_id" select="$comment-nr"/>      
                
                <xsl:variable name="comment-flag">
                   <xsl:call-template name="get-pi-part">
                       <xsl:with-param name="part" select="'flag'"/>
                   </xsl:call-template>
                </xsl:variable>
                <xsl:if test="string-length($comment-flag) > 0">                         
	               	<xsl:attribute name="flag" select="$comment-flag"/>
                </xsl:if>
                
                
                <xsl:choose>
                    <xsl:when test="name() = 'oxy_attributes'">
                        <!-- Take each of the attribute changes (are separated with spaces.) -->
                        <xsl:variable name="s1"
                            select="replace(., '\s*(.*?)=&quot;(.*?)&quot;', '&amp;lt;attribute name=&quot;$1&quot;&amp;gt;$2&amp;lt;/attribute&amp;gt;')"/>
                        <xsl:apply-templates
                            select="saxon:parse(concat('&lt;root>', oxy:unescape($s1), '&lt;/root>'))"
                            mode="attributes-changes">
                            <!-- In order to access the current attributes values -->
                            <xsl:with-param name="ctx" select="following-sibling::*[1]" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        
                        <!-- Author -->
                        <xsl:variable name="author">
                            <xsl:call-template name="get-pi-part">
                                <xsl:with-param name="part" select="'author'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="string-length($author) > 0">
                            <oxy:oxy-author>
                                <xsl:value-of select="$author"/>
                            </oxy:oxy-author>
                        </xsl:if>
                        
                        <!-- Comment. -->
                        <xsl:variable name="comment-text">
                            <xsl:call-template name="get-pi-part">
                                <xsl:with-param name="part" select="'comment'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="string-length($comment-text) > 0">
                            <oxy:oxy-comment-text>
                                <xsl:value-of select="$comment-text" disable-output-escaping="yes"/>
                            </oxy:oxy-comment-text>
                        </xsl:if>
                        
                        <!-- Comment ID. Used for replies. -->
                        <xsl:variable name="comment-id">
                            <xsl:call-template name="get-pi-part">
                                <xsl:with-param name="part" select="'id'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="string-length($comment-id) > 0">
                            <oxy:oxy-comment-id>
                                <xsl:value-of select="$comment-id"/>
                            </oxy:oxy-comment-id>
                        </xsl:if>
                        
                        <!-- Comment parent ID. Used for replies. -->
                        <xsl:variable name="comment-parent-id">
                            <xsl:call-template name="get-pi-part">
                                <xsl:with-param name="part" select="'parentID'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="string-length($comment-parent-id) > 0">
                            <oxy:oxy-comment-parent-id>
                                <xsl:value-of select="$comment-parent-id" />
                            </oxy:oxy-comment-parent-id>
                        </xsl:if>
                        
                        <!-- Content. -->
                        <xsl:variable name="content-text">
                            <xsl:choose>
                                <xsl:when test="name() = 'oxy_insert_start'">
                                    <!-- Split or simple insert? -->
                                    <xsl:variable name="type">
                                        <xsl:call-template name="get-pi-part">
                                            <xsl:with-param name="part" select="'type'"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:variable name="nType" select="normalize-space($type)"/>
                                    <xsl:choose>
                                        <xsl:when test="$nType = 'split'">split</xsl:when>
                                        <xsl:when test="$nType = 'surround'">surround</xsl:when>
                                        <xsl:otherwise>insert</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- Deletion -->
                                    <!-- In the callout show only the text, not the markup. -->
                                    <xsl:variable name="deleted">
                                        <xsl:call-template name="get-pi-part">
                                            <xsl:with-param name="part" select="'content'"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:variable name="deleted-content" 
                                        select="string(saxon:parse(concat('&lt;r>', $deleted, '&lt;/r>'))//text())"
                                    />
                                    <!-- Limit to 50 chars.. -->
                                    <xsl:choose>
                                        <xsl:when test="string-length($deleted-content) > 50">
                                            <xsl:value-of select="substring($deleted-content, 0, 50)"/>..                                            
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$deleted-content"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:if test="string-length($content-text) > 0">
                            <oxy:oxy-content>
                                <xsl:value-of select="$content-text"/>
                            </oxy:oxy-content>
                        </xsl:if>
                        
                        <!-- MID -->
                        <xsl:variable name="mid">
                            <xsl:call-template name="get-pi-part">
                                <xsl:with-param name="part" select="'mid'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="string-length($mid) > 0">
                            <oxy:oxy-mid>
                                <xsl:value-of select="$mid"/>
                            </oxy:oxy-mid>
                        </xsl:if>
                        
                        
                        <!-- Timestamp -->
                        <xsl:variable name="timestamp">
                            <xsl:call-template name="get-pi-part">
                                <xsl:with-param name="part" select="'timestamp'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="string-length($timestamp) > 0">
                            <xsl:variable name="ts">
                                <xsl:call-template name="get-pi-part">
                                    <xsl:with-param name="part" select="'timestamp'"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <oxy:oxy-date>
                                <xsl:call-template name="get-date">
                                    <xsl:with-param name="ts" select="$ts"/>
                                </xsl:call-template>
                            </oxy:oxy-date>
                            <oxy:oxy-hour>
                                <xsl:call-template name="get-hour">
                                    <xsl:with-param name="ts" select="$ts"/>
                                </xsl:call-template>
                            </oxy:oxy-hour>
                            <oxy:oxy-tz>
                                <xsl:call-template name="get-tz">
                                    <xsl:with-param name="ts" select="$ts"/>
                                </xsl:call-template>
                            </oxy:oxy-tz>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <!-- Converts a timestamp to a date using the YYYY/MM/DD format -->
    <xsl:template name="get-date">
        <xsl:param name="ts"/>
        <xsl:value-of select="substring($ts, 1, 4)"/>/<xsl:value-of select="substring($ts, 5, 2)"
        />/<xsl:value-of select="substring($ts, 7, 2)"/>
    </xsl:template>
    
    <!-- Converts a timestamp to a string containing hours, minutes, seconds. -->
    <xsl:template name="get-hour">
        <xsl:param name="ts"/>
        <xsl:variable name="part" select="substring-after($ts, 'T')"/>
        <xsl:value-of select="substring($part, 1,2)"/>:<xsl:value-of select="substring($part, 3,2)"/>:<xsl:value-of select="substring($part,5,2)"/>
    </xsl:template>
    
    <!-- Converts a timestamp to a timezone. -->
    <xsl:template name="get-tz">
        <xsl:param name="ts"/>        
        <xsl:variable name="part" select="substring-after($ts, 'T')"/>
        <xsl:choose>
            <xsl:when test="contains($part,'+')">                
                <xsl:variable name="t" select="substring-after($part, '+')"/>
                <xsl:variable name="t1" select="concat(substring($t, 1, 2), ':', substring($t, 3, 2))"/>                
                <xsl:value-of select="concat('+', $t1)"/>                
            </xsl:when>
            <xsl:when test="contains($part,'-')">
                <xsl:variable name="t" select="substring-after($part, '-')"/>
                <xsl:variable name="t1" select="concat(substring($t, 1, 2), ':', substring($t, 3, 2))"/>
                <xsl:value-of select="concat('-', $t1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'+00:00'"/>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Mark the range end -->
    <xsl:template
        match="
        processing-instruction('oxy_comment_end') |
        processing-instruction('oxy_insert_end')">
        <xsl:if test="$show.changes.and.comments = 'yes'">
            <xsl:variable name="start-name"
                select="concat(substring-before(name(), '_end'), '_start')"/>
            
            <!-- In case of nested comments links the end PI to the start PI -->
            <xsl:variable name="start-mid">
                <xsl:call-template name="get-pi-part">
                    <xsl:with-param name="part" select="'mid'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:variable name="preceding"
                select="
                if (string-length($start-mid) > 0)
                then
                preceding::processing-instruction()
                [name() = $start-name]
                [contains(., concat(' mid=&quot;', $start-mid, '&quot;'))]
                else
                preceding::processing-instruction()
                [name() = $start-name]
                [not(contains(., ' mid=&quot;'))]
                "/>
            
            <xsl:variable name="start-pi" select="$preceding[last()]"/>
            <xsl:variable name="id" select="generate-id($start-pi)"/>
            <xsl:variable name="comment-nr" select="$cmid2nr//mapping[@id = $id]/@nr"/>
            <oxy:oxy-range-end hr_id="{$comment-nr}"/>
        </xsl:if>
    </xsl:template>
    
    
    <!-- 
        The highlight in the editor do not generate anything. 
        The template matching text() is dealing with them. -->
    <xsl:template 
        match="
        processing-instruction('oxy_custom_start') | 
        processing-instruction('oxy_custom_end') "/>
    
    
    
    <xsl:template match="text()" priority="100">
        <xsl:choose>
            <xsl:when test="$show.changes.and.comments = 'yes' and $cmid2nr/mapping">
                <!--  There is at least a comment/change tracking PI -->
                
                <!-- Highlight the inserts -->
                <xsl:variable name="preceding-insert"
                    select="
                    preceding::processing-instruction()
                    [name() = 'oxy_insert_start' or name() = 'oxy_insert_end']"/>
                <xsl:variable name="is-in-insert"
                    select="$preceding-insert[last()]/name() = 'oxy_insert_start'"/>
                
                
                <!-- TODO The highlight is not perfect, it fails on nested comments. -->
                <xsl:variable name="preceding-comment"
                    select="
                    preceding::processing-instruction()
                    [name() = 'oxy_comment_start' or name() = 'oxy_comment_end']"/>
                
                <xsl:variable name="is-in-comment"
                    select="$preceding-comment[last()]/name() = 'oxy_comment_start'"/>
                
                
                <!-- TODO The highlight is not perfect, it fails on nested highlights. -->
                <xsl:variable name="preceding-highlight"
                    select="
                    preceding::processing-instruction()
                    [(name() = 'oxy_custom_start' and contains(., 'type=&quot;oxy_content_highlight&quot;')) or name() = 'oxy_custom_end']"/>
                
                <xsl:variable name="is-in-highlight"
                    select="$preceding-highlight[last()]/name() = 'oxy_custom_start'"/>
                
                
                <!-- Start building the markup for comments, highlights -->
                <xsl:variable name="fragment">
                    <xsl:copy/>
                </xsl:variable>
                
                <!-- Insert -->
                <xsl:variable name="fragment">
                    <xsl:choose>
                        <xsl:when test="$is-in-insert">
                            <oxy:oxy-insert-hl>
                                <xsl:copy-of select="$fragment"/>
                            </oxy:oxy-insert-hl>                            
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$fragment"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <!-- Comment -->
                <xsl:variable name="fragment">
                    <xsl:choose>
                        <xsl:when test="$is-in-comment">
                            <oxy:oxy-comment-hl>
                                <xsl:copy-of select="$fragment"/>
                            </oxy:oxy-comment-hl>                            
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$fragment"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <!-- Color highlight -->
                <xsl:variable name="fragment">
                    <xsl:choose>
                        <xsl:when test="$is-in-highlight">
                            <xsl:variable name="highlight-color">
                                <xsl:call-template name="get-pi-part">
                                    <xsl:with-param name="part" select="'color'"/>
                                    <xsl:with-param name="data" select="$preceding-highlight[last()]"/>
                                </xsl:call-template>
                            </xsl:variable>
                            
                            <oxy:oxy-color-hl color="rgba({$highlight-color},50)">
                                <xsl:copy-of select="$fragment"/>
                            </oxy:oxy-color-hl>                            
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$fragment"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:copy-of select="$fragment"/>                
                
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- Gets a part from the comment PI. -->
    <xsl:template name="get-pi-part">
        <xsl:param name="part"/>
        <xsl:param name="data" select="."/>
        <xsl:variable name="after" select="substring-after($data, concat($part, '=&quot;'))"/>
        <xsl:variable name="before" select="substring-before($after, '&quot;')"/>
        <xsl:value-of select="$before"/>
    </xsl:template>
    
    <xsl:template match="attribute" mode="attributes-changes">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="change" mode="attributes-changes">
        <xsl:param name="ctx" tunnel="yes"/>
        <xsl:variable name="aName" select="../@name"/>
        <oxy:oxy-attribute-change type="{@type}" name="{$aName}">
            <oxy:oxy-author>
                <xsl:value-of select="@author"/>
            </oxy:oxy-author>
            <xsl:if test="@comment">
                <oxy:oxy-comment-text>
                    <xsl:value-of select="@comment"/>
                </oxy:oxy-comment-text>
            </xsl:if>
            <xsl:if test="@oldValue">
                <oxy:oxy-old-value>
                    <xsl:value-of select="@oldValue"/>
                </oxy:oxy-old-value>
            </xsl:if>
            <xsl:variable name="currentValue" select="$ctx/@*[local-name() = $aName]"/>
            <xsl:if test="$currentValue">
                <oxy:oxy-current-value>
                    <xsl:choose>
                        <xsl:when test="$aName = 'id'">
                            <!-- DITA OT is rewriting the values from the @id attribute, so there is no point in showing them.-->
                            <xsl:attribute name="unknown" select="'true'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$currentValue"/>                        
                        </xsl:otherwise>
                    </xsl:choose>
                </oxy:oxy-current-value>
            </xsl:if>
            
            <!-- MID -->
            <xsl:variable name="mid">
                <xsl:call-template name="get-pi-part">
                    <xsl:with-param name="part" select="'mid'"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="string-length($mid) > 0">
                <oxy:oxy-mid>
                    <xsl:value-of select="$mid"/>
                </oxy:oxy-mid>
            </xsl:if>
            
            <oxy:oxy-date>
                <xsl:call-template name="get-date">
                    <xsl:with-param name="ts" select="@timestamp"/>
                </xsl:call-template>
            </oxy:oxy-date>
            <oxy:oxy-hour>
                <xsl:call-template name="get-hour">
                    <xsl:with-param name="ts" select="@timestamp"/>
                </xsl:call-template>
            </oxy:oxy-hour>
            <oxy:oxy-tz>
                <xsl:call-template name="get-tz">
                    <xsl:with-param name="ts" select="@timestamp"/>
                </xsl:call-template>
            </oxy:oxy-tz>
        </oxy:oxy-attribute-change>
    </xsl:template>
    
    <xsl:function name="oxy:unescape" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:variable name="s2" select="replace($in, '&amp;amp;', '&amp;')"/>
        <xsl:variable name="s3" select="replace($s2, '&amp;lt;', '&lt;')"/>
        <xsl:variable name="s4" select="replace($s3, '&amp;gt;', '&gt;')"/>
        <xsl:variable name="s5" select="replace($s4, '&amp;quot;', '&quot;')"/>
        <xsl:variable name="s6" select="replace($s5,'&amp;apos;', &quot;&apos;&quot;)"/>
        <xsl:value-of select="$s6"/>
    </xsl:function>
    
    
    <!--
    	
        Default copy template.
		
    -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>