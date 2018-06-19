<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Propagate the DITA class attribute to the output.
    In this way the print CSSs developed for the direct 
    transformation are common with the ones for the HTML transformation.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- 
        overrides oxygen-dita-ot-2.x/plugins/org.dita.xhtml/xsl/xslhtml/dita2htmlImpl.xsl 
        If you have a task, with 
        
        @class="- topic/topic task/task" 
        
        results in:
        
        @class="- topic/topic task/task topic task"
    -->
  
    <!-- Get the ancestry of the current element (name only, not module) --> 
    <xsl:template match="*" mode="get-element-ancestry">
        <xsl:param name="checkclass" select="@class"/>
        
        <xsl:if test="$checkclass = @class">
            <!-- The first call from the recursion, put the original class value in the front. -->
            <xsl:value-of select="@class"/>  
        </xsl:if>
        
        <!-- Default processing, add the class without the domain. -->    
        <xsl:if test="contains($checkclass, '/')">
            <xsl:variable name="lastpair">
                <xsl:call-template name="get-last-class-pair">
                    <xsl:with-param name="checkclass" select="$checkclass"/>
                </xsl:call-template>
            </xsl:variable>
            <!-- If there are any module/element pairs before the last one, 
          process them and add a space -->
            <xsl:if test="contains(substring-before($checkclass, $lastpair), '/')">
                <xsl:apply-templates select="." mode="get-element-ancestry">
                    <xsl:with-param name="checkclass" select="substring-before($checkclass, $lastpair)"/>
                </xsl:apply-templates>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select="substring-after($lastpair, '/')"/>
        </xsl:if>
        
        
    </xsl:template>
</xsl:stylesheet>