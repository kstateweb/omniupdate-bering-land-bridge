<?xml version="1.0" encoding="UTF-8"?>

<!-- Aborted attempt using push proicessing rather than pull.
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
    
    <!--<xsl:strip-space elements="*"/>-->
    <xsl:preserve-space elements="maincontent prehead extracss bodycode extrajs"/>
    
    <xsl:output method="xml" indent="no" use-character-maps="keep-most-entities"/>
    <xsl:character-map name="keep-most-entities">
        <xsl:output-character character="&#xA0;" string="&amp;nbsp;" />
        <xsl:output-character character="&#x2014;" string="&amp;mdash;" />
        <xsl:output-character character="&#xe000;" string="&lt;" />
        <xsl:output-character character="&#xe001;" string="&gt;" />
        <xsl:output-character character="&#xe002;" string="" />
    </xsl:character-map>
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- Define a variable named nl to hold a linefeed character.
       *
       * To force a newline, use <xsl:value-of select="$nl" />
    -->
    <xsl:variable name="nl" as="xs:string" select="'&#10;'"/>
    
    <xsl:template name="prevent-self-closure">
        <xsl:value-of select="'&#xe002;'" />
    </xsl:template>
    
    
    
    <xsl:template match="/">
        
        <xsl:value-of select="$nl" />
        <xsl:apply-templates select="node()"/>
        
    </xsl:template>
    
    <xsl:template match="processing-instruction('pcf-stylesheet')" priority="10">

        <xsl:if test="count(//processing-instruction('pcf-stylesheet')) gt 1">
            <xsl:message>   Found multiple pcf-stylesheet processing instructions</xsl:message>
        </xsl:if>
        <xsl:processing-instruction name="pcf-stylesheet"
            select="('site=&quot;xsl&quot;', 'path=&quot;/5/standard-level.xsl&quot;',
                'extension=&quot;html&quot;', 'title=&quot;Page&quot;')"/>
        <xsl:value-of select="$nl" />
        
        <xsl:text>&#xe000;!DOCTYPE PUBLIC SYSTEM "http://commons.omniupdate.com/dtd/standard.dtd"&#xe001;</xsl:text>
        
        <xsl:value-of select="$nl || $nl" />
    </xsl:template> 
        
        
    <xsl:template match="/document" priority="10">
        <document>
            <xsl:apply-templates select="node()"/>
        </document>
    </xsl:template>
    
    
    <xsl:template match="/document/config" priority="10">
        <config>
            <xsl:apply-templates select="node()"/>
        </config>
    </xsl:template>
    
    <xsl:template match="/document/config/parameter | /document/config/parameter/option" priority="10">
        <xsl:call-template name="prevent-self-closure"/>
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:apply-templates select="node()"/>
            <xsl:call-template name="prevent-self-closure"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/*" priority="1">
        <xsl:message>Unmatched top-level node: {local-name()}</xsl:message>
    </xsl:template>
        
</xsl:stylesheet>