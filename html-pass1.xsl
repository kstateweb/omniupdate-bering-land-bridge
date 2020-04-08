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
    
    <xsl:template match="p[count(node()) eq 1 and text() and fn:normalize-whitespace(./text()) ne ./text()]" mode="process-html" priority="10020">
        <xsl:variable name="html" as="node()*">
            <xsl:copy>{fn:normalize-whitespace(./text())}</xsl:copy>
        </xsl:variable>
        
        <xsl:apply-templates select="$html" mode="#current" />
    </xsl:template>
    
    
    <xsl:template match="a[starts-with(@href, 'http://')]" mode="process-html" priority="10030">

        <xsl:if test="not(fn:known-good-https(@href))">
            <xsl:message> switching href URL to HTTPS: {@href}</xsl:message>
        </xsl:if>
        
        <xsl:variable name="html" as="node()*">
            <xsl:copy>
                <xsl:attribute name="href" select="replace(@href, 'http://', 'https://')"/>
                <xsl:copy-of select="@*[local-name() ne 'href']"/>
                <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:copy>
        </xsl:variable>

        <xsl:apply-templates select="$html" mode="#current" />
    </xsl:template>

    <xsl:template match="img[starts-with(@src, 'http://')] |
        iframe[starts-with(@src, 'http://')] |
        script[starts-with(@src, 'http://')]" mode="process-html" priority="10030">

        <xsl:if test="not(fn:known-good-https(@src))">
            <xsl:message> switching src URL to HTTPS: {@src}</xsl:message>
        </xsl:if>
        
        <xsl:variable name="html" as="node()*">
            <xsl:copy>
                <xsl:attribute name="src" select="replace(@src, 'http://', 'https://')"/>
                <xsl:copy-of select="@*[local-name() ne 'src']"/>
                <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:copy>
        </xsl:variable>
        
        <xsl:apply-templates select="$html" mode="#current" />
    </xsl:template>

    <xsl:variable name="hostname-list" as="xs:string">
        catalog.k-state.edu
        chronicle.com
        courses.k-state.edu
        issuu.com
        www.k-state.edu
    </xsl:variable>
    
    <xsl:variable name="hostname-map" as="map(xs:string, xs:boolean)">      
        <xsl:map>
            <xsl:for-each select="tokenize(normalize-space(replace($hostname-list, '\s+', ' ')))">
                <xsl:map-entry key="." select="true()"/>
                <!--<xsl:message>good host: '{.}'</xsl:message>-->
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    
    <xsl:function name="fn:known-good-https" as="xs:boolean?">
        <xsl:param name="url" as="xs:string?" />
        <xsl:variable name="hostname" as="xs:string" select="replace($url, '^https?://([^/]+).*$', '$1', 'i')"/>
        
        <xsl:sequence select="$hostname-map($hostname)" />
    </xsl:function>
           
</xsl:stylesheet>