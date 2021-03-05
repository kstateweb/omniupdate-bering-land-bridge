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


    <xsl:template match="*[starts-with(@id, 'yui_')]" mode="process-html" priority="1010">
        
        <xsl:variable name="html" as="node()*">
            <xsl:copy>
                <xsl:copy-of select="@*[not((local-name() eq 'id') and (starts-with(., 'yui_')))]"/>
                <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:copy>
        </xsl:variable>
        
        <xsl:apply-templates select="$html" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="a[@title] | img[@title eq @alt]" mode="process-html" priority="1011">
        
        <xsl:variable name="html" as="node()*">
            <xsl:copy>
                <xsl:copy-of select="@*[local-name() ne 'title']"/>
                <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:copy>
        </xsl:variable>
        
        <xsl:apply-templates select="$html" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*[@style or @class]" mode="process-html" priority="1012">
        
        <xsl:variable name="html" as="node()*">
            <xsl:copy>
                <xsl:copy-of select="@*[not(local-name() = ('style', 'class'))]"/>
                <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:copy>
        </xsl:variable>
        
        <xsl:apply-templates select="$html" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*[@data-mce-mark]" mode="process-html" priority="1013">
        
        <xsl:variable name="html" as="node()*">
            <xsl:copy>
                <xsl:copy-of select="@*[local-name() ne 'data-mce-mark']"/>
                <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:copy>
        </xsl:variable>
        
        <xsl:apply-templates select="$html" mode="#current"/>
    </xsl:template>
    
</xsl:stylesheet>