<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:saxon="http://saxon.sf.net/"
    xmlns:ImageInfo="java:ImageInfo" exclude-result-prefixes="#all ">

    <xsl:output indent="yes"/>

    <xsl:param name="args.input"/>
    <xsl:param name="dita.map.filename.root"/>
    <xsl:param name="chapter.depth">2</xsl:param>
    <xsl:param name="show.changes.and.comments" select="'no'"/>
    <xsl:param name="args.draft" select="'no'"/>
    
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
		
        Create a title page
        
	-->
    <xsl:template match="*[contains(@class, ' map/map ')]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <oxy:front-page>
                <oxy:front-page-title>
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
                <oxy:front-matter>
                    <xsl:apply-templates select="$frontmatter" mode="expand"/>
                </oxy:front-matter>
            </xsl:if>

            <xsl:apply-templates select="node()"/>

            <!-- Bookmap: Expand backmatter -->
            <xsl:variable name="backmatter" select="//*[contains(@class, ' bookmap/backmatter ')]"/>
            <xsl:if test="$backmatter">
                <oxy:back-matter>
                    <xsl:apply-templates select="$backmatter" mode="expand"/>
                </oxy:back-matter>
            </xsl:if>

        </xsl:copy>
    </xsl:template>

    <!-- 
                
        General filtering. 
    
    -->

    <!-- Some attributes are not relevant to our output. -->
    <xsl:template match="@xtrf"/>
    <xsl:template match="@xtrc"/>
    <xsl:template match="@ditaarch:DITAArchVersion"/>
    <xsl:template match="@domains"/>
    <xsl:template match="@keyref"/>
    <xsl:template match="@ohref"/>
    <xsl:template match="@collection-type"/>
    <xsl:template match="@chunk"/>
    <xsl:template match="@resourceid"/>
    <xsl:template match="@first_topic_id"/>
    <xsl:template match="@locktitle"/>

    <!-- The profiling is done already. What is in the document was already filtered by the dita.val. 
        If you need to style based on these attributes, comment the templates below. -->
    <xsl:template match="@product"/>
    <xsl:template match="@audience"/>
    <xsl:template match="@platform"/>
    <xsl:template match="@props"/>
    <xsl:template match="@otherprops"/>

    <xsl:template match="processing-instruction('ditaot')"/>

    <!--
    	
        TOC fixes.
        
    -->
    <!-- Remove the the link text, leave only the navtitle, which has markup. -->
    <xsl:template match="opentopic:map//*[contains(@class, ' map/linktext ')]"/>
    <!-- Remove short descriptions from topicmetas in the toc.-->
    <xsl:template match="opentopic:map//*[contains(@class, ' map/shortdesc ')]"/>
    <!-- Remove the reltables from the toc. -->
    <xsl:template match="opentopic:map//*[contains(@class, ' map/reltable ')]"/>


    <!-- Move the id from the topicref parent to the navtitle.
        The id is declared again in the topic content below. -->
    <xsl:template match="opentopic:map//*[contains(@class, ' map/topicref ')]/@id"/>

    <!-- Exclude references marked as not entering the TOC. -->
    <xsl:template match="opentopic:map//*[contains(@class, ' map/topicref ')][@toc = 'no']" priority="100"/>
 
    <xsl:template match="opentopic:map//*[contains(@class, ' topic/navtitle ')]">
        <xsl:copy>
            <xsl:call-template name="navtitle.href"/>
            <!-- Remove the markup from the <navtitle> children. 
                It causes Prince to break the lines in the TOC before and after each of the 
                inline elements. -->
            <!--   <xsl:apply-templates select="@*|node()"/> -->
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()|*" mode="navtitle"/>            
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/tm ')]" mode="navtitle">
        <xsl:choose>
            <xsl:when test="@tmtype = 'tm'">&#8482;</xsl:when>
            <xsl:when test="@tmtype = 'reg'">&#174;</xsl:when>
            <xsl:when test="@tmtype = 'service'">&#8480;</xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="navtitle.href">
        <xsl:attribute name="href">
            <xsl:variable name="closestTopicref"
                select="ancestor-or-self::*[contains(@class, ' map/topicref ')][1]"/>
            <xsl:variable name="tid" select="$closestTopicref/@first_topic_id"/>
            <xsl:choose>
                <xsl:when test="$tid">
                    <xsl:value-of select="$tid"/>
                </xsl:when>
                <!-- EXM-32190 Sometimes, when we have chunk=to-content on the root element, the first_topic_id attribute might be missing -->
                <xsl:otherwise>
                    <!-- Do not use the @href attribute, it does not point to the topic from the content.
                    Instead, use the @id, it has the same value as the @id from the content. -->
                    <xsl:value-of select="concat('#', $closestTopicref/@id)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <!-- 
        Sometimes the @navtitle attribute on the topicref element is used instead 
        of the <topicmeta>/<navtitle> element.
        DITA OT generates a linktext in this case. To simplify CSS processing,
        we'll create a navtitle out of the linktext.
    -->
    <xsl:template match="opentopic:map//topicmeta[linktext][not(navtitle)]">
        <xsl:copy>
            <navtitle class="- topic/navtitle ">
                <xsl:call-template name="navtitle.href"/>
                <xsl:value-of select="linktext"/>
            </navtitle>
        </xsl:copy>
    </xsl:template>


    <!-- Add a reference to the generated index element -->
    <xsl:template match="opentopic:map">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>

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



    <!-- Mark the chapters, so their titles can be presented differently in the TOC. -->
    <xsl:template
        match="opentopic:map//*[contains(@class,' bookmap/chapter ')] |
               opentopic:map//*[contains(@class,' map/topicref ') and
                        count(ancestor::*[contains(@class,' map/topicref ')]) &lt; $chapter.depth
                 ]">
        <xsl:copy>
            <xsl:attribute name="is-chapter">true</xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Make the bookmap parts transparent to the transformation, it makes the chapter marking cumbersom (see the template below). -->
    <xsl:template match="//opentopic:map/*[contains(@class, ' bookmap/part ')]" priority="200">
        <xsl:apply-templates select="node()"/>
    </xsl:template>


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

    <!-- 
    	
        Images.
        
    -->
    <!-- Convert the href from relative (to the DITA map original file - as it is processed by the DITA-OT 
    previous ant targets) to absolute. -->
    <xsl:template match="*[contains(@class, ' topic/image ')]/@href">
        <xsl:attribute name="href">
            <xsl:value-of select="oxy:absolute-href( .)"/>
        </xsl:attribute>
    </xsl:template>

	<!-- Deals with scaling for images not having a width and height specified in the document. -->
    <xsl:template
        match="*[contains(@class, ' topic/image ')][@href][not(@width)][not(@height)]/@scale">
        
        <xsl:variable name="href" select="oxy:absolute-href(../@href)"/>
        <xsl:variable name="image-size" select="ImageInfo:getImageSize($href)"/>

        <xsl:choose>
            <xsl:when test="not($image-size = '-1,-1')">
                <xsl:variable name="width"
                    select="round(number(substring-before($image-size, ',')) * number(.) div 100)"/>
                <xsl:attribute name="width" select="$width"/>
                <xsl:variable name="height"
                    select="round(number(substring-after($image-size, ',')) * number(.) div 100)"/>
                <xsl:attribute name="height" select="$height"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>Scaling failed for the image <xsl:value-of select="../@href" />.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>

        <!-- Leave the scale attribute in the output. -->
        <xsl:copy/>
    </xsl:template>

    <!-- Fixes the href, converting it from relative (to the DITA map original file) to absolute. -->
    <xsl:function name="oxy:absolute-href" as="xs:string">
        <xsl:param name="href-val" as="xs:string"/>
        
        <xsl:variable name="raw-href">
            <xsl:choose>
                <xsl:when test="not(contains($href-val, '//'))">                    
                    <xsl:variable name="path" select="translate(substring-before($args.input, concat($dita.map.filename.root, '.ditamap')), '\', '/')"/>                    
                    <xsl:variable name="map-dir-uri">
                        <xsl:choose>
                            <xsl:when test="starts-with($path, '/')">
                                <xsl:value-of select="concat('file:',$path)"/>        
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat('file:/',$path)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:value-of select="concat($map-dir-uri, $href-val)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$href-val"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="normalize-space($raw-href)"/>
    </xsl:function>


    <!-- 
        The highlight in the editor do not generate anything. 
        The template matching text() is dealing with them. -->
    <xsl:template 
        match="
        processing-instruction('oxy_custom_start') | 
        processing-instruction('oxy_custom_end') "/>
       

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

                        <!-- Timestamp -->
                        <xsl:variable name="timestamp">
                            <xsl:call-template name="get-pi-part">
                                <xsl:with-param name="part" select="'timestamp'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="string-length($timestamp) > 0">
                            <oxy:oxy-date>
                                <xsl:variable name="ts">
                                    <xsl:call-template name="get-pi-part">
                                        <xsl:with-param name="part" select="'timestamp'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:call-template name="process-timestamp">
                                    <xsl:with-param name="ts" select="$ts"/>
                                </xsl:call-template>
                            </oxy:oxy-date>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- Converts a timestamp using the YYYY/MM/DD format -->
    <xsl:template name="process-timestamp">
        <xsl:param name="ts"/>
        <xsl:value-of select="substring($ts, 1, 4)"/>/<xsl:value-of select="substring($ts, 5, 2)"
            />/<xsl:value-of select="substring($ts, 7, 2)"/>
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
            <oxy:oxy-date>
                <xsl:call-template name="process-timestamp">
                    <xsl:with-param name="ts" select="@timestamp"/>
                </xsl:call-template>
            </oxy:oxy-date>
        </oxy:oxy-attribute-change>
    </xsl:template>


	<!-- Hides or shows the draft comments depending on the DITA-OT args.draft parameter. -->
    <xsl:template match="*[contains(@class, ' topic/draft-comment ')] | *[contains(@class, ' topic/required-cleanup ')] ">
        <xsl:if test="$args.draft = 'yes'">
            <xsl:copy>
                <xsl:apply-templates select="@* | node()"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

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
