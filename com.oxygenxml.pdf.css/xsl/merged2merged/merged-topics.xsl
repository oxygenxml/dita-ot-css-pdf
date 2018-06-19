<!-- 
    
    This stylesheet processes the topics from the main content.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
  xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
  xmlns:opentopic="http://www.idiominc.com/opentopic"
  xmlns:oxy="http://www.oxygenxml.com/extensions/author" xmlns:saxon="http://saxon.sf.net/"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ImageInfo="java:ImageInfo"
  exclude-result-prefixes="#all">

  <!-- 
      Annotate the outputclass attribute with the value form the corresponding topicrefs.
      In this way we can style the topic based on outputclass of the topicref. For instance one 
      can use outputclass="page-break-before", and this value will go on the topic. 
      The page break can be imposed using some CSS rules.
   -->
  <xsl:template match="*[contains(@class, ' topic/topic ')]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      
      <xsl:variable name="topicref" select="key('map-id', concat('#', @id))"/>
      <xsl:if test="$topicref/@outputclass">
        <xsl:choose>
          <xsl:when test="@outputclass">
            <xsl:attribute name="outputclass" select="concat(@outputclass,' ', $topicref/@outputclass)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="outputclass" select="$topicref/@outputclass"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  
  
  <!-- 
    	Annotate the topic title with a @navtitle attribute if it was set on the 
    	referring topicref. In this way we can define the PDF bookmarks correctly.
    -->
  <xsl:template match="*[contains(@class, ' topic/topic ')]/*[contains(@class, ' topic/title ')]">
  
    <xsl:variable name="topic-id" select="../@id"/>
    <xsl:variable name="topicref"
      select="//*[contains(@class, ' map/topicref ')][@locktitle = 'yes'][@id = $topic-id]"/>
    
    <xsl:variable name="topicref-navtitle-element"
      select="$topicref/*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]"/>
    
    <xsl:variable name="topicref-navtitle"
      select="
        if ($topicref-navtitle-element) then
          normalize-space($topicref-navtitle-element)
        else
          $topicref/@navtitle"/>
    
    
    <xsl:choose>
      <xsl:when test="$topicref-navtitle">
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <!-- Add the attribute -->
          <xsl:if test="$topicref-navtitle">
            <xsl:attribute name="navtitle" select="$topicref-navtitle"/>
          </xsl:if>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <!-- The default is to copy the element. -->
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
