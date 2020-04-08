<?xml version="1.0" encoding="UTF-8"?>

<!-- 
-->

<xsl:stylesheet version="3.0" expand-text="yes"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ou="http://omniupdate.com/XSL/Variables"
    xmlns:ouc="http://omniupdate.com/XSL/Variables"
    xmlns:fn="http://www.k-state.edu/xslt/functions"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:saxon="http://saxon.sf.net/"
    exclude-result-prefixes="xs ou ouc fn svg xlink saxon">
    
    <xsl:template match="iframe" mode="process-html" priority="900">
        
        <xsl:message> iframe found, left in PCF</xsl:message>
        
        <xsl:next-match />
        
    </xsl:template>
    
    <xsl:template match="table" mode="process-html" priority="900">
        
        <xsl:message> table found, left in PCF</xsl:message>
        
        <xsl:next-match />
        
    </xsl:template>
    
</xsl:stylesheet>