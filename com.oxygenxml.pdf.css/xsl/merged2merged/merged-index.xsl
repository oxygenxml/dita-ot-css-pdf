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
    
    <!-- If the index structure is empty, do not copy it to the output. -->
    <xsl:template match="opentopic-index:index.groups[count(*) = 0]" priority="2"/>
    
    <!-- By default add a class attibute to the all index elements. 
         In this way the CSS can work for both for merged and HTML5 merged maps. -->
    <xsl:template match="opentopic-index:*" >
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:call-template name="generate-index-element-class"/>
        
        <xsl:apply-templates select="node()"/>
      </xsl:copy>
    </xsl:template>
    
    <xsl:key name="index-leaf-definitions" match="//*[contains(@class, ' topic/topic ')]//opentopic-index:refID[not(../opentopic-index:index.entry)]" use="@value"/>
    <!-- For each refID in the content, make sure there is an @id attribute for it. -->
    <xsl:template match="*[contains(@class, ' topic/topic ')]//opentopic-index:refID">
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <xsl:call-template name="generate-index-element-class"/>
          
          <xsl:attribute name="id">
                <xsl:value-of select="generate-id(.)"/>
          </xsl:attribute>
          <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
  
    <xsl:template match="opentopic-index:index.groups//opentopic-index:refID[@value]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:call-template name="generate-index-element-class"/>

            <xsl:apply-templates select="node()"/>

            <xsl:variable name="for-value" select="@value"/>
            <!-- Find in the content all the definitions that are leafs. Add links from the index to these elements. -->
            <xsl:for-each
                select="key('index-leaf-definitions', $for-value)">
                <oxy:index-link href="#{generate-id(.)}" class=" index/link ">
                  [<xsl:value-of select="generate-id(.)"/>]
                </oxy:index-link>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <!-- Put an id on the index element, this way we can linked it from the table of contents. -->
    <xsl:template match="opentopic-index:index.groups">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:call-template name="generate-index-element-class"/>
            
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id(.)"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    

    <!-- 
        Adds a class attribute to all the index elements. 
     -->
    <xsl:template name="generate-index-element-class">
        <xsl:variable name="local" select="lower-case(local-name())"/>
        <xsl:attribute name="class">
          <xsl:choose>
            <xsl:when test="contains($local, '.')">
                  <xsl:value-of select="concat(' index/', substring-after($local, '.'),' ')"/>
            </xsl:when>
            <xsl:otherwise>
                  <xsl:value-of select="concat(' index/', $local ,' ')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
    </xsl:template>    

    <!-- 
        Deal with <index-see> and <index-see-also>. 
        
        The <index-see> should list the labels of the index terms the user needs to see. 
        No page number should be shown, since this is a pure redirection. 
        
        The <index-see-also> should list the labels of the index terms the user needs to see. 
        The page numbers must be shown.     
    -->
    <!-- No page numbers to the main index term, is a redirection -->
    <xsl:template match="opentopic-index:index.groups//opentopic-index:refID[../opentopic-index:see-childs]" priority="2"/>
    <!-- No page numbers into the list of index terms -->
    <xsl:template match="opentopic-index:index.groups//opentopic-index:see-childs//opentopic-index:refID" priority="2"/>
    <xsl:template match="opentopic-index:index.groups//opentopic-index:see-also-childs//opentopic-index:refID" priority="2"/>
    
    
    
</xsl:stylesheet>