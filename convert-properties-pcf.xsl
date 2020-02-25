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
   
    
    <xsl:template name="properties-pcf">
        <xsl:variable name="input-doc" select="doc(input)"/>

        <xsl:result-document href="file:///{output}" format="pcfoutput">
            <xsl:apply-templates select="$input-doc" mode="properties-pcf"/>
        </xsl:result-document>
    </xsl:template>
        
        
    <xsl:template match="/" mode="properties-pcf">

        <xsl:processing-instruction name="pcf-stylesheet" select="
                ('site=&quot;xsl&quot;', 'path=&quot;/5/properties.xsl&quot;',
                'extension=&quot;inc&quot;', 'title=&quot;Properties&quot;')"/>
        <xsl:value-of select="$nl"/>

        <xsl:text>&#xe000;!DOCTYPE PUBLIC SYSTEM "http://commons.omniupdate.com/dtd/standard.dtd"&#xe001;</xsl:text>

        <xsl:value-of select="$nlnl"/>

        <document>
            <xsl:namespace name="ouc" select="'http://omniupdate.com/XSL/Variables'"/>

            <ouc:properties>
                <parameter name="breadcrumb" type="text" group="Everyone" prompt="Breadcrumb" alt="This folder's breadcrumb">
                    <xsl:call-template name="prevent-self-closure"/>
                    <xsl:value-of select="//parameter[@name = 'breadcrumb']"/>
                </parameter>
            </ouc:properties>

            <xsl:value-of select="$nlnl"/>
        </document>


    </xsl:template>
   
</xsl:stylesheet>