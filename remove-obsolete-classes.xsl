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
    
    <xsl:template match="*[contains(@class, 'beginContent')]" mode="process-html">

        <xsl:variable name="html" as="node()*">
            <xsl:copy>
                <xsl:if test="exists(@class[. ne 'beginContent'])">
                    <xsl:attribute name="class" select="normalize-space(replace(@class, 'beginContent', ''))"/>
                </xsl:if>
                <xsl:copy-of select="@*[local-name() ne 'class']"/>
                <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:copy>
        </xsl:variable>

        <xsl:apply-templates select="$html" mode="#current"/>
    </xsl:template>

</xsl:stylesheet>