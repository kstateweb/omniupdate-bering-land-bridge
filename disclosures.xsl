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
    
    <xsl:template match="*[contains(@class, 'ksu-disclosure-trigger')]" mode="process-html" priority="20000">

        <xsl:variable name="triggertext" as="xs:string" select="data()"/>
        <xsl:variable name="region" as="xs:integer" select="count(preceding::*[contains(@class, 'ksu-disclosure-trigger')]) + 1"/>
        
        ~[com[3343 2 17{{ "version": 17, "data": {{"76a0929ef577e106c0de6266bddb06be":"","83b98e4ed5d4270c1761f368df8ca3eb":"h4","4628d153aa9ca464d9e068850f71f5d7":"","d546333d3ca47d68607a9f63221b3b74":"{fn:encode-html($triggertext)}","e688212722e876873943fb79df29d136":"{$region}"}}}}]]~ 

    </xsl:template>

    <!-- remove disclosure bodies from the normal HTML processing. -->
    <xsl:template match="*[contains(@class, 'ksu-disclosure-body')]" mode="process-html" priority="20000">
        
    </xsl:template>
</xsl:stylesheet>