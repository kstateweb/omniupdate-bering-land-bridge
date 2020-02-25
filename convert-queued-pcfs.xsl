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
    
    <xsl:include href="utilities.xsl" />
    <xsl:include href="convert-pcf.xsl" />
    <xsl:include href="convert-properties-pcf.xsl" />
    
    <!--<xsl:preserve-space elements="*"/>-->
    
    <xsl:output name="pcfoutput" method="xhtml" indent="yes" use-character-maps="keep-most-entities"/>
        
    <xsl:template match="file">
        
        <xsl:message>Processing {displayname}</xsl:message>
        
        <xsl:choose>
            <xsl:when test="matches(input, 'properties\.pcf$')">
                <xsl:call-template name="properties-pcf" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="page-pcf" />
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
        
</xsl:stylesheet>