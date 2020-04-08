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
    
    <xsl:mode name="banner-to-masthead" on-no-match="shallow-skip"/>

<!--    <parameter type="radio" name="banner" prompt="Banner" alt="Banners are supplied by the Division of Communications and Marketing." group="Everyone">
        <option value="none" selected="false">None</option>
        <option value="full" selected="true">Full height, single image</option>
        <option value="half" selected="false">Half height, single image</option>
        <option value="slider" selected="false">Image slider (configuration is in banner-slider-config.pcf)</option>-->

    <xsl:template match="parameter[@name='banner']/option[@value='half' and @selected='true']" mode="banner-to-masthead" priority="110">
        <xsl:message> Half-height banner found -- image will be terrible</xsl:message>
        <xsl:next-match />
    </xsl:template>
        

    <xsl:template match="parameter[@name='banner']/option[@value=('full', 'half') and @selected='true']" mode="banner-to-masthead" priority="100">
        <xsl:variable name="title" as="xs:string" select="fn:title-first-qualifier( (//title/text(), '')[1] )" />

        <p>
            ~[com[3057 1 10{{ "version": 10, "data":
            {{"ca3d8be9d0854e514185f983b029ca76":"{fn:encode-html(//content/banner/img/@src)}",
            "76b240670bacbe9d3e4f974703198dd3":"{fn:encode-html($title)}",
            "75625677885b2648c48697a684854311":"{fn:encode-html(//content/banner/img/@alt)}",
            "528849f801dbf25fdcf1a280ed052648":"",
            "74fd7db458fe6e75622a0f36ba54b099":""}}}}]]~
        </p>

    </xsl:template>


    <xsl:template name="get-img-from-banner-slider" as="element()?">
        <xsl:param name="filename" as="xs:string" select="'banner-slider-config.pcf'"/>
        <xsl:param name="input-file" as="xs:string" tunnel="yes"/>
        
        <xsl:variable name="location" as="document-node()?" select="fn:locate-file($filename, $input-file)"/>
<!--        <xsl:message>{$location/staging/absolute-path}</xsl:message>
        <xsl:message>{unparsed-text-available($location/staging/absolute-path)}</xsl:message>-->
        <xsl:choose>
            <xsl:when test="$location/staging">
                <xsl:sequence select="(doc(substring($location/staging/absolute-path, 2))//slide[enable eq '1']/slide-image/img)[1]" />
            </xsl:when>
            <xsl:otherwise>
                <p>Unable to locate <xsl:value-of select="$filename"/></p>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    
    <xsl:template match="parameter[@name='banner']/option[@value='slider' and @selected='true']" mode="banner-to-masthead" priority="100">
        <xsl:param name="input-file" as="xs:string" tunnel="yes"/>
        <xsl:variable name="title" as="xs:string" select="fn:title-first-qualifier( (//title/text(), '')[1] )" />
        <xsl:variable name="filename" as="xs:string" select="'banner-slider-config.pcf'"/>
        
        <xsl:variable name="img" as="element()?">
            <xsl:call-template name="get-img-from-banner-slider">
                <xsl:with-param name="filename" select="'banner-slider-config.pcf'" />
<!--                <xsl:with-param name="path" select="$input-file" />-->
            </xsl:call-template>
        </xsl:variable>
        
        <p>
            ~[com[3057 1 10{{ "version": 10, "data":
            {{"ca3d8be9d0854e514185f983b029ca76":"{fn:encode-html($img/@src)}",
            "76b240670bacbe9d3e4f974703198dd3":"{fn:encode-html($title)}",
            "75625677885b2648c48697a684854311":"{fn:encode-html($img/@alt)}",
            "528849f801dbf25fdcf1a280ed052648":"",
            "74fd7db458fe6e75622a0f36ba54b099":""}}}}]]~ 
        </p>
        
    </xsl:template>
    
</xsl:stylesheet>