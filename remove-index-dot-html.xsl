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
    
    <xsl:template match="a[ends-with(@href, '/index.html')]" mode="process-html" priority="1000">

        <xsl:variable name="html" as="node()*">
            <xsl:copy>
                <xsl:attribute name="href" select="fn:simplify-url(@href)"/>
                <xsl:copy-of select="@*[local-name() ne 'href']"/>
                <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:copy>
        </xsl:variable>

        <xsl:apply-templates select="$html" mode="#current"/>
    </xsl:template>

</xsl:stylesheet>