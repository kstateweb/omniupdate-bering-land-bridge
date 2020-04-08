<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp   "&#160;">
]>

<!-- XSLT utility functions. -->

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
    
    
    <!-- friendly-boolean, convert a human-entered string value to a boolean.
         
         The normal xs:boolean constructor treats any non-zero length string as true,
         which is nonsensical for a user interface.
         
         This function returns true if the string value is "true", "on", or "yes", potentially with
         leading and trailing whitespace.
         
         Everything else returns false.
     -->
    
    <xsl:function name="fn:friendly-boolean" as="xs:boolean">
        <xsl:param name="val" as="xs:string?" />
        
        <xsl:sequence select="matches($val, '^\s*(yes|on|true)\s*$')" />
        
    </xsl:function>


    <xsl:function name="fn:is-empty" as="xs:boolean">
        <xsl:param name="val" as="item()?" />

        <xsl:sequence select="if (exists(data($val)))
            then matches(data($val), '^\s*$')
            else true()" />
        
    </xsl:function>
    
    <xsl:function name="fn:is-specified" as="xs:boolean">
        <xsl:param name="val" as="item()?" />
        
        <xsl:sequence select="not(fn:is-empty(data($val)))" />
        
    </xsl:function>
    
    
    <xsl:function name="fn:set-default" as="item()">
        <xsl:param name="val" as="item()?" />
        <xsl:param name="default" as="item()" />
        
        <xsl:sequence select="
            if (fn:is-empty($val))
            then $default
            else $val" />
        
    </xsl:function>

    <xsl:function name="fn:optional-query-param" as="xs:string">
        <xsl:param name="name" as="xs:string" />
        <xsl:param name="val" as="xs:string?" />
        
        <xsl:sequence select="
            if (fn:is-empty($val))
                then ''
                else $name || '=' || $val" />
    
    </xsl:function>
    
    
    <xsl:function name="fn:normalize-whitespace" as="xs:string">
        <xsl:param name="val" as="xs:string?" />
        
        <xsl:sequence select="if (exists($val))
            then normalize-space(replace($val, '[\s&nbsp;]', ' '))
            else ''" />
    </xsl:function>
    
    
    <!-- normalize-slash is very similar to normalize-space, but operates on slashes.
        * When concatenating directory paths, sometimes two slashes come together.  For example, concatenating
        * "/one/" and "/two/" gives "/one//two/".  When passed to a file system operation directly, the result will
        * (on most file systems anyway), be the same as "/one/two/".  However, if the program tokenizes the path and
        * walks the directory tree, the extra slash may cause problems.
        *
        * This function leverages normalize-space by:
        * 1.  Using normalize-space on the input path.  This means that paths that legitimately have
        *     multiple consecutive internal blanks, or non-blank whitespace, or leading or trailing whitespace characters
        *     will be mishandled by this function.  (Anybody using such names should be shot anyway.)
        * 2.  Swapping blanks and slashes via the translate function.
        * 3.  Using normalize-space to normalize the slashes.
        * 4.  Swapping back blanks and slashes.
     -->
    <xsl:function name="fn:normalize-slash" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of
            select="translate( normalize-space(translate(normalize-space($string),'/ ', ' /')), '/ ', ' /')"
        />
    </xsl:function>
    
    
    <!-- normalize-path is very similar to normalize-space, but operates on slashes.
        * When concatenating directory paths, sometimes two slashes come together.  For example, concatenating
        * "/one/" and "/two/" gives "/one//two/".  When passed to a file system operation directly, the result will
        * (on most file systems anyway), be the same as "/one/two/".  However, if the program tokenizes the path and
        * walks the directory tree, the extra slash may cause problems.
        *
        * This function leverages normalize-space by:
        * 1.  Using normalize-space on the input path.  This means that paths that legitimately have
        *     multiple consecutive internal blanks, or non-blank whitespace, or leading or trailing whitespace characters
        *     will be mishandled by this function.  (Anybody using such names should be shot anyway.)
        * 2.  Swapping blanks and slashes via the translate function.
        * 3.  Using normalize-space to normalize the slashes.
        * 4.  Swapping back blanks and slashes.
     -->
    <xsl:function name="fn:normalize-path" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:variable name="dedupslash" as="xs:string" select="translate( normalize-space(translate(normalize-space($string),'/ ', ' /')), '/ ', ' /')" />
        <xsl:copy-of select="if ($dedupslash) then $dedupslash else '/'" />
    </xsl:function>
    
    
    <xsl:function name="fn:esc-quote" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:variable name="dquote">&quot;</xsl:variable>
        <xsl:value-of
            select="concat($dquote, replace($string, $dquote, '\$dquote'), $dquote)"
        />
    </xsl:function>
    
    
    <!-- insert-js-property: insert a property into a JavaScript object
       * 
       * This function is passed two required parameters, a name and a value of a property. 
    -->   
    <xsl:function name="fn:insert-js-property" as="xs:string?">
        <xsl:param name="name" as="xs:string" />
        <xsl:param name="value" as="xs:string?" />

        <xsl:if test="string-length($value) > 0">
           <xsl:value-of select="concat($name, ':', fn:esc-quote($value))" />
        </xsl:if>

    </xsl:function>
    
    
    <!-- insert-js-property-boolean: insert a boolean property into a JavaScript object
       * 
       * This function is passed two required parameters, a name and a value of a property.
       * If the value is false, nothing is inserted.  This lets the property be omitted
       * from the JavaScript object.  Accessing the property will then returned undefined,
       * which is falsy.
    -->   
    <xsl:function name="fn:insert-js-property-boolean" as="xs:string?">
        <xsl:param name="name" as="xs:string" />
        <xsl:param name="value" as="xs:boolean?" />

        <xsl:if test="$value">{$name}:true</xsl:if>

    </xsl:function>
    
    
    <!-- isUrl: return boolean true or false based on whether the supplied string is a full URL.
       *
       * The definition of full URL is whether the string starts with "http://" or "https://".
    -->
    
    <xsl:function name="fn:isUrl" as="xs:boolean">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:sequence select="if ($string) then matches($string, '^https?://', 'i') else false()" />
    </xsl:function>


    <!-- not enabled yet -->
<!--    <xsl:template name="fn:read-all-properties" as="element()">
       
        <properties>
            <xsl:variable name="dirs" as="xs:string*" select="tokenize($ou:dirname, '/')" />
            <xsl:for-each select="$dirs">
                <xsl:variable name="site-relative-path" as="xs:string" select="string-join(subsequence($dirs, 1, last()-position()+1), '/')" />

                <xsl:variable name="propfile" as="xs:string"
                    select="$ou:root || '/' || $site-path-prefix || $site-relative-path || '/' || $properties-file" />
                <xsl:message select="'probing ''' || $propfile || ''''" />

                <xsl:if test="doc-available($propfile)">
                    <!-\- Found a properties file.  Add a folder element containing all the parameter elements from the file. -\->
                    <folder path="{if ($site-relative-path) then $site-relative-path else '/'}">
                        <xsl:sequence select="doc($propfile)//parameter" />
                    </folder>
                </xsl:if>

            </xsl:for-each>      

            <!-\- Create an element to contain values inherited from directory variables. -\->
            <directory-variables>
                <parameter name="ga-id">{$ou:google-analytics-website-profile}</parameter> 
            </directory-variables>
            
        </properties>
        
    </xsl:template>-->
    
    <!-- not enabled yet -->
    <!--
    <xsl:function name="fn:get-property" as="xs:string?">
        <xsl:param name="prop" as="xs:string" required="yes"/>
        
        <xsl:sequence select="$properties//parameter[@name=$prop][1]" />
        
    </xsl:function>
    -->
    
    
    <!-- locate-file walks up the directory path
       *
       * Returns a document that contains two elements: <staging> and <prod>.  Each element contains sub-elements
       * that specify how the file can be located on the staging server and the production server, respectively.
       *
       * For example, assuming that a file named "unitmenu.inc" is located in the root of the site named
       * president, then the result may be:
       *
       *   <staging>
       *      <absolute-path>/usr/local/omni/oucampus-kstate/kansas_state_university/president/unitmenu.inc</absolute-path>
       *      <siteroot-relative-path>/president/unitmenu.inc</siteroot-relative-path>
       *   </staging>
       *   <prod>
       *      <absolute-url>http://www.k-state.edu/president/unitmenu.inc</absolute-url>
       *      <hostname-relative-url>/president/unitmenu.inc</hostname-relative-url>
       *      <docroot-relative-path>/president/unitmenu.inc</docroot-relative-path>
       *   </prod>
       *
       * Values in the STAGING element are all file-system paths.
       *
       *    ABSOLUTE-PATH contains the full, absolute path to the file, starting
       *    with the root of the staging server's root file system.
       *
       *    SITEROOT-RELATIVE-PATH contains the path to the file, relative to the
       *    site's document root on the staging server.  The value always starts with a slash.
       *    (This happens to be what the com.omniupdate.div tagging element's path attribute needs.)
       *
       * Values in the PROD element are mostly URLs.
       *
       *    ABSOLUTE-URL contains the absolute URL that can be used to retrieve this file
       *    from the production server.  The protocol is always HTTP.
       *
       *    HOSTNAME-RELATIVE-URL omits the protocol and hostname of the URL, and leaves the path portion.
       *    This is the most suitable way to form URLs on pages managed by OU Campus to other pages
       *    within the same site.  Because the pages will always reside on the same HTTP server, omitting
       *    the protocol and hostname makes the pages smaller and they can be moved between hostnames
       *    without changes.
       *
       *    DOCROOT-RELATIVE-PATH contains the file-system path to the file, relative the the production
       *    HTTP server's document root.
       *
       *    In the example above, the staging/siteroot-relative-path, prod/hostname-relative-url, and 
       *    prod/docroot-relative-path are identical.  However, there are subtle differences.
       *
       *    First, the site configuration may specify that pages are published into a directory that is a 
       *    subdirectory of the production HTTP server's document root.  In this situation, that 
       *    subdirectory name *does* appear in the prod elements, but *does not* appear in the
       *    staging elements.
       *
       *    <detail confusion='true'>
       *    To make it very confusing, the most normal configuration for K-State has pages published
       *    into a subdirectory that happens to match the site name.  In that case, the subdirectory name appears
       *    in URLs.  The site name is one of the qualifiers in the site root.  So the subdirectory name can't
       *    appear in the staging/siteroot-relative-path element, because then the name would appear twice in
       *    the complete path formed by appending the staging/siteroot-relative-path value to the site's
       *    document root.
       *    </detail>
       *
       *    The other way that the staging/siteroot-relative-path and the prod/hostname-relative-url 
       *    elements differ is that the latter is URL-encoded to make it suitable for insertion 
       *    directly into a URL.
       *
       * If the file is not found, no document is returned.
      -->
    <xsl:function name="fn:locate-file" as="document-node()?">
        <xsl:param name="filename" as="xs:string"/>
        <xsl:param name="path" as="xs:string"/>
        
        <!--
           * This function never looks above the directory specified by fs-root when searching for the named file.
           * Regardless of how the slashes are on input, ensure the value always starts and ends with a slash.
         -->
        <xsl:variable name="fs-root" as="xs:string" select="replace($ou:root || $ou:site || '/', '\\', '/')"/>
        <xsl:variable name="fs-path-to-try" as="xs:string" select="$fs-root || fn:normalize-slash($path || '/' || $filename)"/>

        <!--<xsl:message>Looking for {$fs-path-to-try}...</xsl:message>-->
        
        <xsl:choose>
            
            <xsl:when test="unparsed-text-available($fs-path-to-try)">
                <!-- Success: The file is in this directory, return the result document. -->
                <!--<xsl:message>...found.</xsl:message>-->
                <xsl:document>
                    <staging>
                        <absolute-path><xsl:value-of select="$fs-path-to-try"/></absolute-path>
                        <siteroot-relative-path><xsl:value-of select="concat('/',  fn:normalize-slash(concat($path, '/', $filename)))" /></siteroot-relative-path>
                    </staging>
<!--                    <prod>
                        <absolute-url><xsl:value-of select="concat($ou:httproot, fn:normalize-slash(concat($path, '/', encode-for-uri($filename))))" /></absolute-url>
                        <hostname-relative-url><xsl:value-of select="concat('/', fn:normalize-slash(concat($http-site-path-prefix, '/', $path, '/', encode-for-uri($filename))))" /></hostname-relative-url>
                        <docroot-relative-path><xsl:value-of select="concat('/', fn:normalize-slash(concat($http-site-path-prefix, '/', $path, '/', $filename)))" /></docroot-relative-path>
                    </prod>-->
                </xsl:document>
            </xsl:when>

            <xsl:otherwise>
                <!-- Try looking a level up the directory path as long as there is another level. -->
                <xsl:variable name="newpath" as="xs:string" select="replace($path, '/[^/]+$', '')" />
                <xsl:if test="$newpath ne $path and string-length($path) gt 1">
                    <xsl:sequence select="fn:locate-file($filename, $newpath)" />
                </xsl:if>
                <!-- If the above if statement doesn't fire, there is no recursive call, and the
                   * function returns without finding the file.  No document is returned.
                -->
                
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:function>


    <!-- title-first-qualifier returns the text before a pipe character.
       * This is very similar to the standard substring-before function.  However, that function returns
       * a null string if the separation character is not present in the original string.  In other words,
       * substring-before("foo", "|") returns "".  This function returns "foo".
       *
       * Futhermore, this function strips leading and trailing whitespace from the returned value.
       *
      -->
    <xsl:function name="fn:title-first-qualifier" as="xs:string">
        <xsl:param name="title" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="contains($title, '|')">
                <xsl:value-of select="normalize-space(substring-before($title,'|'))" /></xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="normalize-space($title)" /></xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>


    <!-- remove-path-prefix removes specified directories from the beginning of a path.
       *
       * The first parameter is the path to be operated on.
       * 
       * The second parameter is the prefix to be removed, if present.
       *
       * Both parameters to this function are paths, and slashes inside the paths
       * are only significant between directory names.  Leading, trailing, and duplicate
       * internal slashes are removed by the normalize-space function.  In other words, the following
       * paths are treated identically: "cat/dog", "/cat/dog/", "cat//dog", "//cat///dog//".
       * Also, "/" is the same as "//" and "".
       *
       * Only complete directories are removed.
       *
       * Examples:
       *    fn:remove-path-prefix("cat/dog", "cat")      ==>  "dog"
       *    fn:remove-path-prefix("cat/dog", "")         ==>  "cat/dog"
       *    fn:remove-path-prefix("cat/dog", "mouse")    ==>  "cat/dog"
       *    fn:remove-path-prefix("cat/dog", "cat/dog")  ==>  ""
       *    fn:remove-path-prefix("cat/dog", "cat/dog/mouse")  ==>  "cat/dog"
       *    fn:remove-path-prefix("cat/dog", "ca")       ==>  "cat/dog"
       *
      -->
    <xsl:function name="fn:remove-path-prefix" as="xs:string">
        <xsl:param name="path" as="xs:string"/>
        <xsl:param name="prefix" as="xs:string"/>
        
        <xsl:variable name="path-slash" as="xs:string" select="concat(fn:normalize-slash($path), '/')" />
        <xsl:variable name="prefix-slash" as="xs:string" select="concat(fn:normalize-slash($prefix), '/')" />
        
        <xsl:value-of select="fn:normalize-slash(
            if (starts-with($path-slash, $prefix-slash))
               then substring($path-slash,string-length($prefix-slash)+1) 
               else $path)" />
        
    </xsl:function>


    <!-- remove-path-suffix removes specified directories from the end of a path.
       *
       * The first parameter is the path to be operated on.
       * 
       * The second parameter is the suffix to be removed, if present.
       *
       * See the description of remove-path-prefix for more details.
       *
    -->
    <xsl:function name="fn:remove-path-suffix" as="xs:string">
        <xsl:param name="path" as="xs:string"/>
        <xsl:param name="suffix" as="xs:string"/>
        
        <xsl:variable name="slash-path" as="xs:string" select="concat('/', fn:normalize-slash($path))" />
        <xsl:variable name="slash-suffix" as="xs:string" select="concat('/', fn:normalize-slash($suffix))" />
        
        <xsl:value-of select="if (ends-with($slash-path, $slash-suffix))
            then substring($slash-path, 1, string-length($slash-path)-string-length($slash-suffix))
            else fn:normalize-slash($path)" />
        
    </xsl:function>
    
    
    <!-- remove-protocol removes the scheme from a URL.
       *
       * The only parameter is the URL to be operated on.
       * 
       * If the URL does not start with "http:" or "https:", then the URL is returned unchanged.
       * Otherwise, the protocol and colon are removed.
       *
       * The purpose of this function is to be able to form protocol-agnostic URLs in web pages.
       *
       * Examples:
       *
       *    http://www.example.com/path      ==> //www.example.com/path
       *    http://www.example.com/          ==> //www.example.com/
       *    http://www.example.com           ==> //www.example.com
       *    https://www.example.com/path     ==> //www.example.com/path
       *    //www.example.com/path           ==> //www.example.com/path
    -->
    <xsl:function name="fn:remove-protocol" as="xs:string">
        <xsl:param name="url" as="xs:string"/>
        
        <xsl:value-of select="replace($url, '^(https?:)', '')" />
    </xsl:function>
    
    
    <!-- remove-hostname removes the scheme and hostname from a URL.
       *
       * The only parameter is the URL to be operated on.
       * 
       * If the URL does not have a hostname, then the URL is returned unchanged.
       *
       * If the URL has a hostname, but no scheme, the hostname is still removed.
       *
       * If the URL has no path part, then "/" is returned.
       *
       * Examples:
       *
       *    http://www.example.com/path      ==> /path
       *    http://www.example.com/path/     ==> /path/
       *    http://www.example.com/          ==> /
       *    http://www.example.com           ==> /
       *    https://www.example.com/path     ==> /path
       *    //www.example.com/path           ==> /path
    -->
    <xsl:function name="fn:remove-hostname" as="xs:string">
        <xsl:param name="url" as="xs:string"/>
        
        <xsl:value-of select="replace($url, '^([^/]+:)?//[^/]+', '')" />
    </xsl:function>
    
    
    <!-- get-hostname - return the hostname from a URL.
       *
       * The only parameter is the URL to be operated on.
       * 
       * If the URL does not use the http or https protocol, then an empty sequence is returned.
       * 
       * If the URL does not have a hostname, then an empty sequence is returned.
       *
       *
       * Examples:
       *
       *    http://www.example.com/path      ==> www.example.com
       *    http://www.example.com/          ==> www.example.com
       *    http://www.example.com           ==> www.example.com
       *    https://www.example.com/path     ==> www.example.com
       *    //www.example.com/path           ==> www.example.com
       *    /path                            ==>                  (empty sequence)
       *    path                             ==>                  (empty sequence)
       *    file://C:/path                   ==>                  (empty sequence)
    -->
    <xsl:function name="fn:get-hostname" as="xs:string?">
        <xsl:param name="url" as="xs:string"/>
        
        <xsl:variable name="no-protocol" select="replace($url, '^https?:', '')" />
        <xsl:if test="starts-with($no-protocol, '//')">
            <xsl:value-of select="replace(substring($no-protocol, 3), '/.*', '')" />
        </xsl:if>
    </xsl:function>
    
    
    <!-- get-subset-search-url - return the hostname from a URL.
       *
       * The only parameter is the URL to be operated on.
       * 
       * If the URL does not use the http or https protocol, then an empty sequence is returned.
       * 
       * If the URL does not have a hostname, then an empty sequence is returned.
       *
       *
       * Examples:
       *
       *    http://www.example.com/path/     ==> www.example.com/path
       *    http://www.example.com/path      ==> www.example.com/path
       *    http://www.example.com/          ==> www.example.com
       *    http://www.example.com           ==> www.example.com
       *    https://www.example.com/path     ==> www.example.com/path
       *    //www.example.com/path           ==> www.example.com
       *    /path                            ==>                  (empty sequence)
       *    path                             ==>                  (empty sequence)
       *    file://C:/path                   ==>                  (empty sequence)
    -->
    <xsl:function name="fn:get-subset-search-url" as="xs:string?">
        <xsl:param name="url" as="xs:string"/>
        
        <xsl:variable name="no-protocol" select="replace($url, '^https?:', '')" />
        <xsl:if test="starts-with($no-protocol, '//')">
            <xsl:value-of select="replace(substring($no-protocol, 3), '/+$', '')" />
        </xsl:if>
    </xsl:function>
    
    
    <!-- include-branding-html adds code to include an HTML file from the K-State branding resources.
       *
       * The first parameter is the filename to be included.  Only the filename is needed, not the path,
       * because HTML branding assets are always pulled from a single directory.
       *
       * Normally when a file is included, a server-side include is used with either a
       * standard Apache/HTTP server-side include (SSI) or a PHP include statement.
       *
       * However, SSIs can only include files from the same server, and PHP doesn't run on the OU staging server.
       * Thus when a page is used on the staging server in either Preview or edit modes, the fragment is
       * read through the file system at XSLT translation time.
       * This also means that such fragments have to be duplicated on the staging server and all the production servers.
    -->
<!--    <xsl:template name="include-branding-html">
        <xsl:param name="filename" as="xs:string?"/>

        <xsl:choose>
            <!-\- Nothing to include?  Just skip it then.  -\->
            <xsl:when test="not($filename)" />
                
            <xsl:when test="$ou:action = ('prv','edt') or $ou:include-method eq 'none'">
                <xsl:value-of select="unparsed-text($staging-branding-include-path || '/' || $filename)" disable-output-escaping="yes"/>
           </xsl:when>
           <xsl:when test="$ou:include-method eq 'SSI'">
               <!-\- The SSI include won't work if the ou:http-resource-scheme-host is not null. -\->
               <xsl:comment>#include virtual="<xsl:value-of select="fn:remove-hostname($http-branding-url) || '/html/' || $filename"/>"</xsl:comment>
           </xsl:when>
            <xsl:when test="$ou:include-method eq 'PHP'">
                <xsl:processing-instruction name="php">
                   readfile($_SERVER['DOCUMENT_ROOT'] . '<xsl:value-of select="$ou:http-resource-path || $ou:branding-path || '/html/' || $filename"/>'); 
                ?</xsl:processing-instruction>
            </xsl:when>
            <xsl:otherwise>
                Invalid include-method: '<xsl:value-of select="$ou:include-method" />'
            </xsl:otherwise>
       </xsl:choose>
    </xsl:template>-->
    
    
    <!-- Find and include a named file by searching up the directory path. -->
    <!-- Note this can't be used to include a file that must be pulled in on the staging server. -->
<!--    <xsl:template name="include-file">
        <xsl:param name="filename" as="xs:string" required="yes"/>
        <xsl:param name="path" as="xs:string" select="$ou:dirname"/>
        
        <xsl:variable name="location" as="document-node()?" select="fn:locate-file($filename, $path)"/>
        <xsl:choose>
            <xsl:when test="$location/staging">
                <ouc:div group="Everyone" button-text="Edit" label="label-{$filename}" path="{$location/staging/siteroot-relative-path/text()}">
                <ouc:editor csspath="/foo.css" />
                <xsl:choose>
                    <xsl:when test="$ou:include-method eq 'SSI'">
                        <xsl:comment>#include virtual="<xsl:value-of select="$location/prod/hostname-relative-url/text()"/>" </xsl:comment>
                    </xsl:when>
                    <xsl:when test="$ou:include-method eq 'PHP'">
                        <xsl:processing-instruction name="php">
                           include $_SERVER['DOCUMENT_ROOT'] . '<xsl:value-of select="$location/prod/docroot-relative-path/text()"/>'; 
                        ?</xsl:processing-instruction>
                    </xsl:when>
                    <xsl:when test="$ou:include-method eq 'none'">
                        <xsl:value-of select="unparsed-text($location/staging/absolute-path/text())" disable-output-escaping="yes"/>
                    </xsl:when>
                   
                    <xsl:otherwise>
                        Invalid include-method: '<xsl:value-of select="$ou:include-method" />'
                    </xsl:otherwise>
                </xsl:choose>
                   
                </ouc:div>
            </xsl:when>
            <xsl:otherwise>
                <p>Unable to locate <xsl:value-of select="$filename"/></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->



    <!-- Find and include a named file by searching up the directory path. -->
<!--    <xsl:template name="include-pcf">
        <xsl:param name="filename" as="xs:string" required="yes"/>
        <xsl:param name="path" as="xs:string" select="$ou:dirname"/>
        <xsl:param name="ext" as="xs:string" select="'.html'"/>
        <xsl:param name="mode" as="xs:string" select="'#current'"/>    <!-\- It looks like mode can be removed. -\->
        <xsl:param name="silent-fail" as="xs:boolean" select="false()"/>
        <xsl:param name="not-found-fallback" as="item()*">
            <p>Unable to locate {$filename}</p>
        </xsl:param>
        
        <!-\-<xsl:message>calling locate-file({$filename}, {$path}), {$ou:dirname}</xsl:message>-\->
        
        <xsl:variable name="location" as="document-node()?" select="fn:locate-file($filename, $path)"/>
        <xsl:choose>
            <xsl:when test="$location/staging">
                <xsl:choose>
                    <xsl:when test="$is-publish and $ou:include-method eq 'SSI'">
                        <xsl:comment>#include virtual="<xsl:value-of select="replace($location/prod/hostname-relative-url/text(), '\.pcf$', $ext)"/>"</xsl:comment>
                    </xsl:when>
                    <!-\- Should handle PHP method here -\->
                    <xsl:otherwise>
                        <xsl:variable name="doc" as="document-node()" select="doc($location/staging/absolute-path)"/>
                        <xsl:choose>
                            <xsl:when test="$mode eq 'horizontal-menu'">
                                <xsl:apply-templates select="$doc" mode="horizontal-menu">
                                    <xsl:with-param name="included-file-url" select="$location/prod/hostname-relative-url/text()" />
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:when test="$mode eq 'unit-menu'">
                                <xsl:apply-templates select="$doc/document/node()">
                                    <xsl:with-param name="included-file-url" select="$location/prod/hostname-relative-url/text()" />
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="$doc/document/node()" mode="#current">
                                    <xsl:with-param name="included-file-url" select="$location/prod/hostname-relative-url/text()" />
                                </xsl:apply-templates>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$silent-fail" />
            <xsl:otherwise>{$not-found-fallback}
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->
    
    
    
    
    <!--  -->
    <xsl:template name="include-region">
        <xsl:param name="region" as="xs:string" required="yes"/>

        <xsl:apply-templates select="/document/ouc:div[@label=$region]" mode="process-html" />

    </xsl:template>



    <!--
         Convert a configuration string into an XML document.
         
         Configuration strings follow a syntax familiar to programmers: a series of assignment statements.
         Values are either character strings, numbers, or boolean.  Character strings
         can be delimited with either single or double quotes.  There is no provision for including
         both single and double quotes in the same string.
         Assignment statements are ended with a semicolon, optional for the last assignment.  
            
         This template function turns assignment statements into an XML document of the form where each
         variable is an element, with an enclosed value.  There is an outer CONFIG element, with a nested
         VAR element for each assignment statement.  For the examples above the results would be:
         
            title="Hello"                           <var name="title">Hello</var>
            title='Hello'                           <var name="title">Hello</var>
            title='Hello';                          <var name="title">Hello</var>
            title='Hello'; subtitle="world";        <var name="title">Hello</var><var name="subtitle">world</var>
            width = 32;                             <var name="width">32</var>
            topbar = false;                         <var name="topbar">false</var>
            
         If an unparsable statement is found, a SYNTAX-ERROR element is added, with a text node inside containing
         the invalid character sequence.
         
            title="h                                <syntax-error>title="h</syntax-error>
         
         
    -->
    <xsl:template name="parse-config" as="document-node()?">
        <xsl:param name="config" as="xs:string?"/>
        <xsl:variable name="quotes">'"</xsl:variable>
        
        <xsl:document>
            <config>
                <xsl:analyze-string select="concat($config, ';')" regex="\s*(\p{{L}}(\p{{L}}|-|[0-9])*)\s*=\s*(('([^']*)')|(&quot;([^&quot;]*)&quot;)|true|false|[^'&quot;][^'&quot;;]*)\s*;">
                    <xsl:matching-substring>
                        <var name="{regex-group(1)}">
                            <xsl:value-of select="if (regex-group(4)) then regex-group(5) else if (regex-group(6)) then regex-group(7) else regex-group(3)"/>
                        </var>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:if test="not(matches(., '^[\s;]*$'))">
                           <syntax-error><xsl:value-of select="." /></syntax-error>
                        </xsl:if>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </config>
            
        </xsl:document>
        
    </xsl:template>
    
    
    
    <xsl:template name="table-to-js-object" as="text()*">
        
        <xsl:text>{{</xsl:text>
        <xsl:for-each select="tbody/tr">
            <!-- Should worry about encoding the values -->
            <xsl:variable name="name" as="xs:string" select="normalize-space(replace((if (count(th) > 1) then th[1] else th), '&#xa0;', ' '))" />
            <xsl:variable name="value" as="xs:string" select="normalize-space(replace((if (count(td) > 1) then td[1] else td), '&#xa0;', ' '))" />
            <xsl:if test="$name ne ''">
                "<xsl:value-of select="$name" />":"<xsl:value-of select="$value" />"<xsl:if test="position() ne last()">,</xsl:if>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>}}</xsl:text>
    </xsl:template>
    
    
    <xsl:function name="fn:convert-config-to-json">
        <xsl:param name="config" as="item()*"/>
        
        <xsl:text>{{</xsl:text>
        
        <xsl:for-each select="$config/var">"{@name}":"{text()}"<xsl:if test="position() ne last()">,</xsl:if>
        </xsl:for-each>
        
        <xsl:text>}}</xsl:text>
    </xsl:function>
    
    
    <xsl:template name="optional-link" as="item()*">
        <xsl:param name="linktext" as="item()*" />
        <xsl:param name="url" as="xs:string?" />
        <xsl:param name="class" as="xs:string?" />
        
        <xsl:choose>
            <xsl:when test="$url ne '' and exists($linktext)">
                <a href="{$url}">
                    <xsl:if test="$class ne ''">
                        <xsl:attribute name="class" select="$class" />
                    </xsl:if>
                    <xsl:copy-of select="$linktext"/>
                </a>
            </xsl:when>
            <xsl:when test="exists($linktext)">
                <xsl:copy-of select="$linktext"/>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- Remove-unused-links isn't currently used. -->
    <xsl:template name="remove-unused-links" as="node()*">
        <xsl:param name="linktext" as="node()*" />

        <xsl:apply-templates select="$linktext" mode="remove-unused-links" />
    </xsl:template>
    
    <xsl:mode name="remove-unused-links" on-no-match="shallow-copy"/>
    
    <xsl:template match="a[string-length(@href) eq 0]" mode="remove-unused-links">
        <xsl:apply-templates select="node()" mode="#current" />
    </xsl:template>
    
    <!-- Add a query parameter and value to a query string
       *
       * The base query parameter may be specified with no leading '?',
       * or with a leading '?', or for convenience, a leading '&'.
       *
       * The result will have a leading '?' unless the result is empty.
       *
    -->
    <xsl:function name="fn:append-query-param" as="xs:string">
        <xsl:param name="base-param" as="xs:string?" />
        <xsl:param name="param-name" as="xs:string?" />
        <xsl:param name="param-value" as="xs:string?" />
        
        <!-- Remove a leading '?' or '&' on the base query parameter. -->
        <xsl:variable name="base" as="xs:string?"
            select="replace($base-param, '^[\?&amp;]', '')" />
       
        <xsl:choose>

            <!-- If both the base and the added parameter are missing, return an empty string. -->
            <xsl:when test="string-length($base) eq 0 and string-length($param-name) eq 0">
                <xsl:sequence select="''"/>
            </xsl:when>

            <!-- If the base is missing, return the added parameter and value. -->
            <xsl:when test="string-length($base) eq 0">
                <xsl:sequence select="'?' || $param-name || '=' || $param-value"/>
            </xsl:when>

            <!-- If the added parameter is missing, or is already in the base, return the base.
               * XSLT regular expressions don't support \b as a break metacharacter, thus the
               * prepend with '?' and test for a non-alphanumeric character before the 
               * parameter-name.
            -->
            <xsl:when
                test="
                    string-length($param-name) eq 0 or
                    matches('?' || $base, '[^a-zA-Z0-9]' || $param-name || '=')">
                <xsl:sequence select="'?' || $base"/>
            </xsl:when>

            <!-- Otherwise, add the parameter and value -->
            <xsl:otherwise>
                <xsl:sequence select="
                '?' || $base || '&amp;' || $param-name || '=' || $param-value"/>
            </xsl:otherwise>

        </xsl:choose>
        
    </xsl:function>
    
    <!-- Region configuration is represented by a map from the region name to boolean true()
       * for enabled regions.  Regions not enabled are not added to the map.  Retrieving a
       * non-enabled region returns the empty sequence, which is falsy.
       *
       * The result is that testing for a region name can be done via "$regions?regionname".
    -->
    <xsl:template name="checkbox-map" as="map(xs:string, xs:boolean)">
        <xsl:param name="parameter-name" as="xs:string" required="yes" />
        <xsl:param name="override" as="xs:string*" />
        
        <xsl:map>
            <xsl:for-each select="//ouc:properties/parameter[@name=$parameter-name]/option[@selected='true']">
                <xsl:map-entry key="string(@value)" select="true()"/>
            </xsl:for-each>
            <xsl:for-each select="$override">
                <xsl:map-entry key="." select="true()"/>
            </xsl:for-each>
            
        </xsl:map>
    </xsl:template>

    <xsl:function name="fn:encode-html" as="xs:string?">
        <xsl:param name="html" as="xs:string?" />
        
        <xsl:sequence
            select="replace($html, '&amp;', '&amp;amp;')" />
    </xsl:function>
    
</xsl:stylesheet>