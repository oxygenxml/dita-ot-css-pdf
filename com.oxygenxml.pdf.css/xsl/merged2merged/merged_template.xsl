<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="#all">

    <xsl:import href="merged-all.xsl"/>
    
    <!-- XSLT extension point for the DITA merged file post-processing, before entering other phases. -->
    <dita:extension id="com.oxygenxml.pdf.css.merged2merged.xsl"
                  behavior="org.dita.dost.platform.ImportXSLAction"
                  xmlns:dita="http://dita-ot.sourceforge.net"/>
    
    
    <!-- XSLT extension point defined from a publishing template file. -->
    <xsl:import href="template:xsl/com.oxygenxml.pdf.css.xsl.merged2merged"/> 
</xsl:stylesheet>
