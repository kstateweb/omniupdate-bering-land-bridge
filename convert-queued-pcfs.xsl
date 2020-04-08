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
    <xsl:include href="utility-functions.xsl" />
    <xsl:include href="convert-pcf.xsl" />
    <xsl:include href="convert-properties-pcf.xsl" />
    
    <!-- OmniUpdate parameters supplied to the XSLT transform, in alphabetical order.
       * Parameters not used in the tranformation are not included.
       * OU Campus always supplies values for all of these.  However, when run locally in oXygen,
       * paramters are usually omitted.  Thus default values are supplied so that the XSLT optimizer
       * can still be assured that these are all supplied.
     -->
    <xsl:param name="ou:action" as="xs:string" select="''" />
    <xsl:param name="ou:site" as="xs:string" select="''" />
    <xsl:param name="ou:path" as="xs:string" select="''" />
    <xsl:param name="ou:dirname" as="xs:string" select="''" />
    <xsl:param name="ou:filename" as="xs:string" select="''" />
    <xsl:param name="ou:username" as="xs:string" select="''" />
    <xsl:param name="ou:modified" as="xs:dateTime?" />
    <xsl:param name="ou:root" as="xs:string" select="''" />
    <xsl:param name="ou:httproot" as="xs:string" select="''" />
    
    <!--<xsl:preserve-space elements="*"/>-->
    <xsl:strip-space elements="*"/>
    
    <xsl:output name="pcfoutput" method="xml" indent="yes" use-character-maps="keep-most-entities"/>
        
    <xsl:template match="file">
        
        <xsl:message>Processing {displayname}</xsl:message>
                
        <xsl:choose>
            <xsl:when test="matches(input, 'properties\.pcf$')">
                <xsl:call-template name="properties-pcf" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="page-pcf">
                    <xsl:with-param name="input-file" as="xs:string" select="input" tunnel="yes"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
        
</xsl:stylesheet>