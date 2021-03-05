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
   
    
    <xsl:template name="horizontal-menu-pcf">
        <xsl:variable name="input-doc" select="doc(input)"/>

        <xsl:result-document href="file:///{output}" format="pcfoutput">
            <xsl:apply-templates select="$input-doc" mode="horizontal-menu-pcf"/>
        </xsl:result-document>
    </xsl:template>
        
        
    <xsl:template match="/" mode="horizontal-menu-pcf">

        <xsl:processing-instruction name="pcf-stylesheet" select="
                ('site=&quot;xsl&quot;', 'path=&quot;/4/menu-standalone.xsl&quot;',
                'extension=&quot;html&quot;', 'title=&quot;Menu&quot;', 'publish=&quot;no&quot;')"/>
        <xsl:processing-instruction name="pcf-stylesheet" select="
                ('site=&quot;xsl&quot;', 'path=&quot;/4/menu-standalone-json.xsl&quot;',
                'extension=&quot;json&quot;', 'title=&quot;JSON&quot;', 'alternate=&quot;yes&quot;')"/>
        <xsl:value-of select="$nl"/>

        <xsl:text>&#xe000;!DOCTYPE PUBLIC SYSTEM "http://commons.omniupdate.com/dtd/standard.dtd"&#xe001;</xsl:text>

        <xsl:value-of select="$nlnl"/>
        
        <document>
            <xsl:namespace name="ouc" select="'http://omniupdate.com/XSL/Variables'"/>
            
            <ouc:properties label="config">
                <parameter type="checkbox" name="menus" prompt="Include menu" group="Everyone">
                    <option value="horiz" selected="true">Horizontal menu</option>
                </parameter>
            </ouc:properties>
            
            <xsl:value-of select="$nlnl"/>
            
            <ouc:div label="menu" group="Everyone" button-text="Edit menu"><ouc:editor csspath="/ksu-resources/ou/editor/css/menu.css"/>
                <xsl:apply-templates select="(//ul)[1]" mode="#current" />
            </ouc:div>

            <xsl:value-of select="$nlnl"/>
        </document>

    </xsl:template>
    
    <xsl:template match="ul" mode="horizontal-menu-pcf">
        <ul>
            <xsl:apply-templates select="li" mode="#current" />
        </ul>
        
    </xsl:template>
    
    <xsl:template match="li" mode="horizontal-menu-pcf">
        <xsl:param name="input-file" as="xs:string" tunnel="yes" />
        <li>
            <a href="{fn:simplify-url(a/@href)}">{a/text()}</a>
            
            <xsl:variable name="path-to-start" as="xs:string"
                select="replace($input-file, '/horizontal-menu.pcf', a/@href)"/>
            
            <xsl:if test="starts-with(a/@href, '/')">
                <xsl:call-template name="get-unitmenu">
                    <xsl:with-param name="url-param" select="$path-to-start"/>
                </xsl:call-template>
            </xsl:if>
        </li>
        
    </xsl:template>
    
    
    <xsl:template name="get-unitmenu" as="element()?">
        <xsl:param name="url-param" as="xs:string"/>
        
        <!-- TODO: This is a hack for the specific site.  Pass from somewhere. -->
        <xsl:variable name="url" as="xs:string" select="replace($url-param, '/sfa/', '/')"/>
        
        <xsl:variable name="filename" as="xs:string" select="'unitmenu.inc'"/>
        
        <xsl:variable name="location" as="document-node()?" select="fn:locate-file($filename, $url)"/>
<!--        <xsl:message>{$url}</xsl:message>
        <xsl:message>available: {$location/staging/absolute-path}: {unparsed-text-available($location/staging/absolute-path)}</xsl:message> 
-->
        
        <xsl:choose>
            <xsl:when test="$location/staging">
                <xsl:message>   inserting {$location/staging/absolute-path}</xsl:message>

                <xsl:variable name="unitmenu" as="xs:string" select="unparsed-text($location/staging/absolute-path)" />
                <xsl:apply-templates select="parse-xml(fn:fix-xml-string($unitmenu))" mode="unitmenu-inc" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>   unable to locate '{$filename}' starting at '{$url}'</xsl:message>
                <p>Unable to locate '{$filename}' starting at '{$url}'</p>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:mode on-no-match="shallow-copy" />
    
    <xsl:template match="comment()" mode="unitmenu-inc" />
    
    <xsl:template match="ul" mode="unitmenu-inc">
        <ul>
            <xsl:apply-templates select="*" mode="#current" />
        </ul>
    </xsl:template>   
    
    <xsl:template match="li" mode="unitmenu-inc">
        <li>
            <xsl:apply-templates select="*" mode="#current" />
        </li>
    </xsl:template>

    <xsl:template match="a" mode="unitmenu-inc">
        <a href="{fn:simplify-url(@href)}">{text()}</a>
    </xsl:template>
    
    
    <xsl:function name="fn:fix-xml-string" as="xs:string">
        <xsl:param name="xmlstring" as="xs:string" />
        
        <xsl:sequence select="replace($xmlstring, '&amp;nbsp;', ' ')" />
    </xsl:function>
    
</xsl:stylesheet>