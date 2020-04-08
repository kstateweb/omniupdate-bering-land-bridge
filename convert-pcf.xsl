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
    
    <xsl:include href="html-pass1.xsl" />
    <xsl:include href="banner-to-masthead.xsl" />
    <xsl:include href="promote-headings.xsl" />
    <xsl:include href="remove-obsolete-classes.xsl" />
    <xsl:include href="remove-useless-attributes.xsl" />
    <xsl:include href="warn-iframe-table.xsl" />
    <xsl:include href="warn-flash.xsl" />
    <xsl:include href="remove-bold-headings.xsl" />
    <xsl:include href="remove-useless-headings.xsl" />
    <xsl:include href="remove-index-dot-html.xsl" />
    <xsl:include href="warn-obsolete-table-transforms.xsl" />
    <xsl:include href="disclosures.xsl" />
    
    
    
    <xsl:template name="page-pcf">
        
        <xsl:variable name="input-doc" select="doc('file:///' || input/text())"/>
        <xsl:variable name="promote-headings" as="xs:boolean" select="not(exists($input-doc//h1) or exists($input-doc//h2))"/>
        
<!--        <xsl:variable name="pass1" as="document-node()">
            <xsl:document>
                <xsl:apply-templates select="$input-doc" mode="page-pcf"/>
            </xsl:document>
        </xsl:variable>-->
        
        <xsl:result-document href="file:///{output}" format="pcfoutput">
            <xsl:apply-templates select="$input-doc" mode="page-pcf"/>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template match="/" mode="page-pcf">

        <xsl:if test="count(//processing-instruction('pcf-stylesheet')) gt 1">
            <xsl:message> found multiple pcf-stylesheet processing instructions</xsl:message>
        </xsl:if>
        
        <xsl:if test="string-length(normalize-space(string-join(//extracss/node()))) gt 0">
            <xsl:message> found non-empty extracss element</xsl:message>
        </xsl:if>    
        
        <xsl:if test="string-length(normalize-space(string-join(//extrajs/node()))) gt 0">
            <xsl:message> found non-empty extrajs element</xsl:message>
        </xsl:if>    

        <xsl:if test="count(//script) gt 0">
            <xsl:message> found {count(//script)} script block(s)</xsl:message>
        </xsl:if>
        
        <xsl:if test="count(//style) gt 0">
            <xsl:message> found {count(//style)} style block(s)</xsl:message>
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
            <xsl:value-of select="$nlnl"/>
            
            <xsl:variable name="title" as="xs:string?" select="(//title/text(), '')[1]" />
            <xsl:if test="string-length(normalize-space($title)) eq 0">
                <xsl:message> No title found</xsl:message>
            </xsl:if>

            <ouc:properties label="metadata">
                <title>{fn:title-first-qualifier($title)}</title>
                <meta name="keywords" content="{//meta[@name='keywords']/@content}"/>
                <meta name="description" content="{//meta[@name='description']/@content}"/>
                <meta name="author" content="{//meta[@name='author']/@content}"/>
            </ouc:properties>
            <xsl:value-of select="$nl"/>

            <ouc:properties label="config">
                <parameter type="text" name="stitle" prompt="Short title" alt="Used for the breadcrumb.  If omitted, the full title is used.">
                    <xsl:call-template name="prevent-self-closure"/>
                </parameter>

                <xsl:variable name="has-banner" as="xs:boolean"
                    select="exists(//parameter[@name='banner']/option[@value=('full', 'half', 'slider') and @selected='true'])"/>
                
                <parameter type="checkbox" name="regions" prompt="Include regions" group="Everyone">
                    <option value="masthead" selected="{if ($has-banner) then 'true' else 'false'}">Masthead</option>
                    <option value="unit-menu" selected="true">Sidebar: Unit menu</option>
                    <option value="contact-sidebar" selected="false">Sidebar: Contact information</option>
                    <option value="cta-layer" selected="false">Call to action layer</option>
                    <option value="contact-layer" selected="false">Contact information layer</option>
                </parameter>
            </ouc:properties>
            <xsl:value-of select="$nl"/>

            <ouc:div label="masthead" group="Everyone" button-text="Edit masthead">
                <xsl:call-template name="prevent-self-closure" />
                
                <xsl:apply-templates select="//parameter" mode="banner-to-masthead"/>
            </ouc:div>
            <xsl:value-of select="$nl"/>

            <ouc:div label="maincontent" group="Everyone" button-text="Edit main content">
                <ouc:editor csspath="/ksu-resources/ou/editor/maincontent.css" cssmenu="/ksu-resources/ou/editor/maincontent-classes.txt"/>
                <xsl:call-template name="process-html">
                    <xsl:with-param name="html" as="node()*" select="/document/content/maincontent/node()"/>
                </xsl:call-template>
            </ouc:div>
            <xsl:value-of select="$nl"/>
            
            <xsl:variable name="disclosure-bodies" as="element()*" select="//*[contains(@class, 'ksu-disclosure-body')]" />
            <xsl:for-each select="$disclosure-bodies">
                
                <ouc:div label="{position()}" group="Everyone" button-text="Edit">
                    <ouc:editor csspath="/ksu-resources/ou/editor/maincontent.css" cssmenu="/ksu-resources/ou/editor/maincontent-classes.txt"/>
                    
                    <xsl:variable name="html" as="node()*">
                        <xsl:copy>
                            <xsl:copy-of select="@*[local-name() ne 'class']"/>
                            <xsl:apply-templates select="node()" mode="process-html"/>
                        </xsl:copy>
                    </xsl:variable>
                    
                    <xsl:apply-templates select="$html" mode="process-html"/>
                </ouc:div>
            </xsl:for-each>
            
            <xsl:for-each select="count($disclosure-bodies)+1 to 30">
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
                            <xsl:value-of select="$nl"/>
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
    
    <!-- Remove any TYPE attribute of script or style elements -->
    <xsl:template match="script | style" mode="process-html">
        <xsl:copy>
            <xsl:copy-of select="@*[local-name() ne 'type']" />
            <xsl:apply-templates select="node()"/>
            <xsl:call-template name="prevent-self-closure"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Remove SPAN elements that have no attributes.  This is potentially
       * damaging because even attribute-less SPANs may be targeted by CSS and JavaScript. -->
    <xsl:template match="span[count(@*) eq 0]" mode="process-html">
        <xsl:apply-templates select="node()" mode="#current" />
    </xsl:template>
    
    <xsl:template match="span[count(@*) gt 0]" mode="process-html">
        <xsl:message> found SPAN element with attributes -- left in PCF</xsl:message>
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:apply-templates select="node()" mode="#current" />
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template name="process-html">
        <xsl:param name="html" as="node()*" />
        
        <xsl:variable name="pass1" as="document-node()">
            <xsl:document>
                <xsl:apply-templates select="$html" mode="promote-headings"/>
            </xsl:document>
        </xsl:variable>
        
        <xsl:apply-templates select="$pass1" mode="process-html"/>
        
<!--        <xsl:variable name="pass1" as="node()*">
            <xsl:apply-templates select="$html" mode="process-html"/>
        </xsl:variable>
        
        <xsl:variable name="pass2" as="node()*">
            <xsl:apply-templates select="$pass1" mode="html-pass2"/>
        </xsl:variable>
        
        <xsl:variable name="pass3" as="node()*">
            <xsl:apply-templates select="$pass2" mode="html-pass3"/>
        </xsl:variable>
        
        <xsl:sequence select="$pass3"/>-->
    </xsl:template>
    
    <xsl:template match="comment()" mode="process-html" />
    
    <!--        <xsl:template match="text()">
            <xsl:variable name="text1" select="."/>
            
            <xsl:value-of select="$text"/>
        </xsl:template>
--></xsl:stylesheet>