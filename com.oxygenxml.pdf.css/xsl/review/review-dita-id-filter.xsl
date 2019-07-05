<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs saxon oxy" version="2.0"
  xmlns:oxy="http://www.oxygenxml.com/extensions/author" xmlns:saxon="http://saxon.sf.net/" xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/" extension-element-prefixes="saxon">



  <xsl:function name="oxy:getOriginalDITAIDValue" as="item()*">
    <xsl:param name="currentValue" />

      <xsl:analyze-string regex="^unique_(\d+)_Connect_(\d+)_(.*?)$" select="$currentValue">
        <xsl:matching-substring>
          <xsl:value-of select="regex-group(3)" />
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:value-of select="$currentValue" />
        </xsl:non-matching-substring>
      </xsl:analyze-string>

  </xsl:function>

</xsl:stylesheet>