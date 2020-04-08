<?xml version="1.0" encoding="UTF-8"?>

<!-- 
-->

<xsl:stylesheet version="3.0" expand-text="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ou="http://omniupdate.com/XSL/Variables" xmlns:ouc="http://omniupdate.com/XSL/Variables" xmlns:fn="http://www.k-state.edu/xslt/functions"
    xmlns:svg="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:saxon="http://saxon.sf.net/"
    exclude-result-prefixes="xs ou ouc fn svg xlink saxon">

    <xsl:mode name="promote-headings" on-no-match="shallow-copy"/>
    
    <xsl:template match="h1 | h2 | h3 | h4 | h5 | h6" mode="promote-headings" priority="50">

        <!-- If the heading contains only text nodes that combine to just whitespace, stop processing to omit the heading. -->
        <xsl:if test="not((count(node()) eq count(text())) and string-length(fn:normalize-whitespace(text())) eq 0)">
            <xsl:next-match/>
        </xsl:if>

    </xsl:template>


    <xsl:template match="h1 | h2 | h3 | h4 | h5 | h6" mode="promote-headings" priority="40">

        <xsl:choose>

            <!-- If the heading contains only image nodes, just output them without the heading. -->
            <xsl:when test="count(node()) eq count(img)">
                <xsl:apply-templates select="img" mode="#current"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="h3[not(exists(//h1) or exists(//h2))]" mode="promote-headings" priority="30">

            <h1>
                <xsl:copy-of select="@*"/>
                <xsl:sequence select="node()"/>
            </h1>
        
    </xsl:template>

    <xsl:template match="h4[not(exists(//h1) or exists(//h2))]" mode="promote-headings" priority="30">
            <h2>
                <xsl:copy-of select="@*"/>
                <xsl:sequence select="node()"/>
            </h2>
    </xsl:template>

    <xsl:template match="h5[not(exists(//h1) or exists(//h2))]" mode="promote-headings" priority="30">
            <h3>
                <xsl:copy-of select="@*"/>
                <xsl:sequence select="node()"/>
            </h3>
    </xsl:template>

    <xsl:template match="h6[not(exists(//h1) or exists(//h2))]" mode="promote-headings" priority="30">
            <h4>
                <xsl:copy-of select="@*"/>
                <xsl:sequence select="node()"/>
            </h4>
    </xsl:template>

</xsl:stylesheet>