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

    <!-- Match and handle old-style HTML-based disclosures.
     -->
    <xsl:template match="*[contains(@class, 'ksu-disclosure-trigger')]" mode="process-html" priority="20000">

        <xsl:call-template name="insert-disclosure">
            <xsl:with-param name="triggertext"  as="xs:string" select="data()"/>
        </xsl:call-template>

    </xsl:template>
    
    <!-- Match and handle new-style Snippet/table transform-based disclosures.
       *
       * Code looks like:
       *    <table class="ksu-feature-config" data-ksu-feature-name="disclosure" data-ksu-snippet-name="disclosure/0.9.1"><caption>Disclosure configuration</caption>
       *    <tbody>
       *    <tr>
       *    <td>summary</td>
       *    <td> ...HTML of the trigger...</td>
       *    </tr>
       *    <tr>
       *    <td>details</td>
       *    <td> ...HTML of the body... </td>
       *    </tr>
       *    </tbody>
       *    </table>
     -->
    <xsl:template match="table[@data-ksu-feature-name eq 'disclosure']" mode="process-html" priority="20000">
        
        <xsl:call-template name="insert-disclosure">
            <xsl:with-param name="triggertext"  as="xs:string" select="data(.//tr[1]/td[2])"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="insert-disclosure">
        <xsl:param name="triggertext" as="xs:string" required="yes" />
        <xsl:variable name="region" as="xs:integer" select="count(preceding::*[contains(@class, 'ksu-disclosure-trigger')]) + count(preceding::table[@data-ksu-feature-name eq 'disclosure']) + 1"/>
        
        ~[com[3343 2 17{{ "version": 17, "data": {{"76a0929ef577e106c0de6266bddb06be":"","83b98e4ed5d4270c1761f368df8ca3eb":"h4","4628d153aa9ca464d9e068850f71f5d7":"","d546333d3ca47d68607a9f63221b3b74":"{fn:encode-html($triggertext)}","e688212722e876873943fb79df29d136":"{$region}"}}}}]]~ 
        
    </xsl:template>

    <!-- remove disclosure bodies from the normal HTML processing. -->
    <xsl:template match="*[contains(@class, 'ksu-disclosure-body')]" mode="process-html" priority="20000" />
    
    
    <xsl:template name="insert-disclosure-bodies">
        <xsl:variable name="disclosure-bodies" as="element()*" select="//*[contains(@class, 'ksu-disclosure-body')] | //table[@data-ksu-feature-name eq 'disclosure']"/>
        <xsl:for-each select="$disclosure-bodies">
            
            <ouc:div label="{position()}" group="Everyone" button-text="Edit">
                <ouc:editor csspath="/ksu-resources/ou/editor/maincontent.css"
                    cssmenu="/ksu-resources/ou/editor/maincontent-classes.txt"/>

                <xsl:variable name="html" as="node()*">
                    
                    <xsl:choose>
                        <xsl:when test="local-name() eq 'table'">
                            <xsl:apply-templates select=".//tr[2]/td[2]/node()" mode="process-html"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy>
                                <xsl:copy-of select="@*[local-name() ne 'class']"/>
                                <xsl:apply-templates select="node()" mode="process-html"/>
                            </xsl:copy>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:variable>
                    
                <xsl:apply-templates select="$html" mode="process-html"/>
            </ouc:div>
        </xsl:for-each>
        
        <xsl:for-each select="count($disclosure-bodies) + 1 to 30">
            <ouc:div label="{.}" group="Everyone" button-text="Edit">
                <ouc:editor csspath="/ksu-resources/ou/editor/maincontent.css"
                    cssmenu="/ksu-resources/ou/editor/maincontent-classes.txt"/>
            </ouc:div>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>