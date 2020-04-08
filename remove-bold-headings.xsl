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
    
<!--    <xsl:template match="
        strong[ancestor::h1 or ancestor::h2 or ancestor::h3 or
        ancestor::h4 or ancestor::h5 or ancestor::h6] |
        b[ancestor::h1 or ancestor::h2 or ancestor::h3 or
        ancestor::h4 or ancestor::h5 or ancestor::h6]" mode="process-html">

        <!-\- normally there would be an xsl:copy element to copy the node.  However,
               * the whole point is to *not* copy the strong node.
        -\->
        <xsl:apply-templates select="node()" mode="#current"/>

    </xsl:template>-->

</xsl:stylesheet>