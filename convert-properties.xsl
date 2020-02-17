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
    
    <xsl:preserve-space elements="*"/>
    
    <xsl:output method="xhtml" indent="yes" use-character-maps="keep-most-entities"/>
    <xsl:character-map name="keep-most-entities">
        <xsl:output-character character="&#xA0;" string="&amp;nbsp;" />
        <xsl:output-character character="&#x2014;" string="&amp;mdash;" />
        <xsl:output-character character="&#xe000;" string="&lt;" />
        <xsl:output-character character="¶" string="" />
        <xsl:output-character character="&#xe001;" string="&gt;" />
        <xsl:output-character character="&#xe002;" string="" />
    </xsl:character-map>
    
    <!-- Define a variable named nl to hold a linefeed character.
       *
       * To force a newline, use <xsl:value-of select="$nl" />
    -->
    <xsl:variable name="nl" as="xs:string" select="'&#10;'"/>
    <xsl:variable name="nlnl" as="xs:string" select="'&#10;&#10;'"/>
    
    
    <xsl:template name="prevent-self-closure">
        <xsl:value-of select="'&#xe002;'" />
    </xsl:template>
    
    <xsl:template match="/">
        
        <xsl:processing-instruction name="pcf-stylesheet"
            select="('site=&quot;xsl&quot;', 'path=&quot;/5/properties.xsl&quot;',
                'extension=&quot;inc&quot;', 'title=&quot;Properties&quot;')"/>
        <xsl:value-of select="$nl" />

        <xsl:text>&#xe000;!DOCTYPE PUBLIC SYSTEM "http://commons.omniupdate.com/dtd/standard.dtd"&#xe001;</xsl:text>
        
        <xsl:value-of select="$nlnl" />
        
        <document>
            <xsl:namespace name="ouc" select="'http://omniupdate.com/XSL/Variables'"/>
            
            <ouc:properties>
                <parameter name="breadcrumb" type="text" group="Everyone" prompt="Breadcrumb" alt="This folder's breadcrumb">
                    <xsl:call-template name="prevent-self-closure"/>
                    <xsl:value-of select="//parameter[@name='breadcrumb']"/>
                </parameter>
            </ouc:properties>
            
            <xsl:value-of select="$nlnl" />
        </document>
            
    </xsl:template>
   
</xsl:stylesheet>