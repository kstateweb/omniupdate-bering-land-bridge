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
    
    
    <xsl:template name="page-pcf">
        
        <xsl:variable name="input-doc" select="doc('file:///' || input/text())"/>
        
        <xsl:result-document href="file:///{output}" format="pcfoutput">
            <xsl:apply-templates select="$input-doc" mode="page-pcf"/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="/" mode="page-pcf">

        <xsl:if test="count(//processing-instruction('pcf-stylesheet')) gt 1">
            <xsl:message>   found multiple pcf-stylesheet processing instructions</xsl:message>
        </xsl:if>
        
        <xsl:if test="string-length(normalize-space(string-join(//extracss/node()))) gt 0">
            <xsl:message>   found non-empty extracss element</xsl:message>
        </xsl:if>    
        
        <xsl:if test="string-length(normalize-space(string-join(//extrajs/node()))) gt 0">
            <xsl:message>   found non-empty extrajs element</xsl:message>
        </xsl:if>    

        <xsl:if test="count(//script) gt 0">
            <xsl:message>   found {count(//script)} script block(s)</xsl:message>
        </xsl:if>
        
        <xsl:if test="count(//style) gt 0">
            <xsl:message>   found {count(//style)} style block(s)</xsl:message>
        </xsl:if>
 
        <xsl:value-of select="$nl" />
        <xsl:processing-instruction name="pcf-stylesheet"
            select="('site=&quot;xsl&quot;', 'path=&quot;/5/standard-level.xsl&quot;',
                'extension=&quot;html&quot;', 'title=&quot;Page&quot;')"/>
        <xsl:value-of select="$nl" />
        
        <xsl:text>&#xe000;!DOCTYPE PUBLIC SYSTEM "http://commons.omniupdate.com/dtd/standard.dtd"&#xe001;</xsl:text>
        
        <xsl:value-of select="$nlnl" />
        
        <document>
            <xsl:namespace name="ouc" select="'http://omniupdate.com/XSL/Variables'"/>
            <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
            <xsl:value-of select="$nl"/>

            <ouc:properties label="metadata">
                <title>{(//title)[1]/text()}</title>
                <meta name="keywords" content="{//meta[@name='keywords']/@content}"/>
                <meta name="description" content="{//meta[@name='description']/@content}"/>
                <meta name="author" content="{//meta[@name='author']/@content}"/>
            </ouc:properties>
            <xsl:value-of select="$nl"/>

            <ouc:properties label="config">
                <parameter type="text" name="stitle" prompt="Short title" alt="Used for the breadcrumb.  If omitted, the full title is used.">
                    <xsl:call-template name="prevent-self-closure"/>
                </parameter>

                <parameter type="checkbox" name="regions" prompt="Include regions" group="Everyone">
                    <option value="masthead" selected="false">Masthead</option>
                    <option value="box-above" selected="false">Sidebar: Box above unit menu</option>
                    <option value="unit-menu" selected="true">Sidebar: Unit menu</option>
                    <option value="box-below" selected="false">Sidebar: Box below unit menu</option>
                    <option value="contact-sidebar" selected="false">Sidebar: Contact information</option>
                    <option value="cta-layer" selected="false">Call to action layer</option>
                    <option value="contact-layer" selected="false">Contact information layer</option>
                </parameter>
            </ouc:properties>
            <xsl:value-of select="$nl"/>

            <ouc:div label="masthead" group="Everyone" button-text="Edit masthead"/>
            <xsl:value-of select="$nl"/>

            <ouc:div label="maincontent" group="Everyone" button-text="Edit main content">
                <ouc:editor csspath="/ksu-resources/ou/editor/maincontent.css" cssmenu="/ksu-resources/ou/editor/maincontent-classes.txt"/>
                <xsl:apply-templates select="/document/content/maincontent/node()" mode="process-html"/>
            </ouc:div>
            <xsl:value-of select="$nl"/>

            <xsl:for-each select="1 to 3">
                <ouc:div label="{.}" group="Everyone" button-text="Edit">
                    <ouc:editor csspath="/ksu-resources/ou/editor/maincontent.css" cssmenu="/ksu-resources/ou/editor/maincontent-classes.txt"/>
                </ouc:div>
            </xsl:for-each>
            <xsl:value-of select="$nlnl"/>

            <!-- copy potentially multiple extracss elements, now named headcode. -->
            <xsl:sequence>
                <xsl:for-each select="//extracss">
                    <xsl:choose>
                        <xsl:when test="not(exists(*)) and string-length(normalize-space(.)) eq 0"/>
                        <xsl:otherwise>
                            <xsl:comment>end of head</xsl:comment>
                            <headcode>
                                <xsl:copy-of select="@*"/>
                                <xsl:call-template name="prevent-self-closure"/>
                                <xsl:apply-templates select="node()" mode="process-html"/>
                            </headcode>
                            <xsl:value-of select="$nlnl"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:on-empty>
                    <xsl:comment>end of head</xsl:comment>
                    <headcode><xsl:call-template name="prevent-self-closure"/></headcode>
                </xsl:on-empty>
            </xsl:sequence>
            <xsl:value-of select="$nlnl"/>

            <!-- Create an empty placeholder for bodycode -->
            <xsl:comment>start of body</xsl:comment>
            <bodycode>
                <xsl:call-template name="prevent-self-closure"/>
            </bodycode>
            <xsl:value-of select="$nlnl"/>


            <!-- copy potentially multiple extrajs elements, now named footcode. -->
            <xsl:sequence>
                <xsl:for-each select="//extrajs">
                    <xsl:choose>
                        <xsl:when test="not(exists(*)) and string-length(normalize-space(.)) eq 0"/>
                        <xsl:otherwise>
                            <xsl:comment>end of body</xsl:comment>
                            <footcode>
                                <xsl:copy-of select="@*"/>
                                <xsl:call-template name="prevent-self-closure"/>
                                <xsl:apply-templates select="node()" mode="process-html"/>
                            </footcode>
                            <xsl:value-of select="$nlnl"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:on-empty>
                    <xsl:comment>end of body</xsl:comment>
                    <footcode><xsl:call-template name="prevent-self-closure"/></footcode>
                </xsl:on-empty>
            </xsl:sequence>
            <xsl:value-of select="$nlnl"/>
            
        </document>        
    </xsl:template>
    
    <xsl:template match="script | style" mode="process-html">
        <xsl:copy>
            <xsl:copy-of select="@*[local-name() ne 'type']" />
            <xsl:apply-templates select="node()"/>
            <xsl:call-template name="prevent-self-closure"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="span[count(@*) eq 0]" mode="process-html">
        <xsl:apply-templates select="node()" mode="#current" />
    </xsl:template>
    
    <xsl:template match="span[count(@*) gt 0]" mode="process-html">
        <xsl:message>   found SPAN element with attributes -- left in PCF</xsl:message>
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:apply-templates select="node()" mode="#current" />
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*" mode="process-html">
        <xsl:copy>
            <xsl:copy-of select="@*[not( (local-name() eq 'id') and (starts-with(., 'yui-')))]" />
            <xsl:apply-templates select="node()" mode="#current" />
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="comment()" mode="process-html" />
    
    <!--        <xsl:template match="text()">
            <xsl:variable name="text1" select="."/>
            
            <xsl:value-of select="$text"/>
        </xsl:template>
--></xsl:stylesheet>