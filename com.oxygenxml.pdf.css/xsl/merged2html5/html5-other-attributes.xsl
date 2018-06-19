<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Propagate the DITA attributes to the output.
    In this way the print CSSs developed for the direct 
    transformation are common with the ones for the HTML transformation.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- Copied from: org.dita.html5/xsl/topic.xsl -->
    <!-- Process standard attributes that may appear anywhere. Previously this was "setclass" -->
    <xsl:template name="commonattributes">
        <xsl:param name="default-output-class"/>
        
        <!-- DCP: Forward the attributes as they are. Latter templates may overwrite the attributes. -->
        <xsl:for-each select="@* except (@xtrf, @xtrc)">
            <xsl:copy/>
        </xsl:for-each>
        
        <xsl:apply-templates select="@xml:lang"/>
        <xsl:apply-templates select="@dir"/>
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/@outputclass" mode="add-ditaval-style"/>
        <xsl:apply-templates select="." mode="set-output-class">
            <xsl:with-param name="default" select="$default-output-class"/>
        </xsl:apply-templates>
        <xsl:if test="exists($passthrough-attrs)">
            <xsl:for-each select="@*">
                <xsl:if test="$passthrough-attrs[@att = name(current()) and (empty(@val) or (some $v in tokenize(current(), '\s+') satisfies $v = @val))]">
                    <xsl:attribute name="data-{name()}" select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>