<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:lxslt="http://xml.apache.org/xslt"
    xmlns:redirect="http://xml.apache.org/xalan/redirect"
    xmlns:stringutils="xalan://org.apache.tools.ant.util.StringUtils"
    extension-element-prefixes="redirect">
<xsl:output method="html" encoding="utf-8" indent="yes" />
<xsl:decimal-format decimal-separator="." grouping-separator=","/>
<!--
   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 -->

<!--

 Sample stylesheet to be used with Ant JUnitReport output.

 It creates a set of HTML files a la javadoc where you can browse easily
 through all packages and classes.

-->
<xsl:param name="output.dir" select="'.'"/>
<xsl:param name="TITLE">Unit Test Results.</xsl:param>


<xsl:template match="testsuites">

    <!-- create the all.html -->
    <redirect:write file="{$output.dir}/all.html">
        <xsl:call-template name="all.html"/>
    </redirect:write>

    <!-- create the overview.html -->
    <redirect:write file="{$output.dir}/index.html">
        <xsl:call-template name="index.html"/>
    </redirect:write>
    
    <!-- generate individual reports per test case -->
    <xsl:for-each select="./testsuite[not(./@package = preceding-sibling::testsuite/@package)]">
        <xsl:call-template name="package">
            <xsl:with-param name="name" select="@package"/>
        </xsl:call-template>
    </xsl:for-each>

    <!-- create the stylesheet.css -->
    <redirect:write file="{$output.dir}/stylesheet.css">
        <xsl:call-template name="stylesheet.css"/>
    </redirect:write>
    
    <!-- create the boilerplate.css -->
    <redirect:write file="{$output.dir}/boilerplate.css">
        <xsl:call-template name="boilerplate.css"/>
    </redirect:write> 

</xsl:template>


<!-- Process each package -->
<xsl:template name="package">
    <xsl:param name="name" />
    <xsl:variable name="package.dir">
        <xsl:if test="not($name = '')"><xsl:value-of select="translate($name,'.','/')"/></xsl:if>
        <xsl:if test="$name = ''">.</xsl:if>
    </xsl:variable>
    
    <xsl:for-each select="/testsuites/testsuite[@package = $name]">
	    <redirect:write file="{$output.dir}/{$package.dir}/{@id}_{@name}.html">
            <xsl:apply-templates select="." mode="testsuite.page">
            </xsl:apply-templates>
	    </redirect:write>
    </xsl:for-each>
</xsl:template>

<!-- One file per test suite / class -->
<xsl:template match="testsuite" name="testsuite" mode="testsuite.page">
<html>
    <head>
        <title><xsl:value-of select="@name"/></title>
        <xsl:call-template name="create.stylesheet.link">
			<xsl:with-param name="package.name" select="@package" />
        </xsl:call-template>
    </head>
    <body>
    
        <div id="report">
            <hgroup>
	            <xsl:call-template name="create.logo.link">
		            <xsl:with-param name="package.name" select="@package" />
		        </xsl:call-template>
		        
	            <h1><xsl:value-of select="@name"/></h1>
	            <h2>Package: <xsl:value-of select="@package" /></h2>
            </hgroup>
            
            <xsl:apply-templates select="." mode="summary">
                <xsl:sort select="@errors + @failures" data-type="number" order="descending" />
                <xsl:sort select="@name" />
            </xsl:apply-templates>
        </div>
    
    </body>
</html>
</xsl:template>


<xsl:template name="all.html" match="testsuites" mode="all.tests">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
<html>
    <head>
        <title><xsl:value-of select="$TITLE"/></title>
        <link href="boilerplate.css" rel="stylesheet" type="text/css" />        
        <link href="stylesheet.css" rel="stylesheet" type="text/css" />
    </head>
    <body>
    
        <xsl:variable name="testCount" select="sum(testsuite/@tests)"/>
        <xsl:variable name="errorCount" select="sum(testsuite/@errors)"/>
        <xsl:variable name="failureCount" select="sum(testsuite/@failures)"/>
        <xsl:variable name="timeCount" select="sum(testsuite/@time)"/>
        <xsl:variable name="successRate" select="($testCount - $failureCount - $errorCount) div $testCount"/>
        <xsl:variable name="successCount" select="($testCount - $failureCount - $errorCount)"/>            
    
        <div id="report">
            <div class="grailslogo"></div>
        
            <h1><xsl:value-of select="$TITLE"/></h1>
        
            <p class="intro">
                Executed <xsl:value-of select="$testCount" /> tests, <xsl:value-of select="$errorCount" /> errors and <xsl:value-of select="$failureCount" /> failures.
             
            </p>
            <br style="clear: both" />
            
            <xsl:apply-templates select="testsuite" mode="summary">
                <xsl:sort select="@errors + @failures" data-type="number" order="descending" />
                <xsl:sort select="@name" />
            </xsl:apply-templates>
        
        </div>
        
        <!-- maybe another day
        <script language="javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"></script>
        <script language="javascript">
            $(document).ready(function() {
            });
        </script>  -->
            
    </body>
</html>
</xsl:template>

<xsl:template name="index.html" match="testsuites" mode="all.tests">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
<html>
    <head>
        <title><xsl:value-of select="$TITLE"/></title>
        <link href="boilerplate.css" rel="stylesheet" type="text/css" />        
        <link href="stylesheet.css" rel="stylesheet" type="text/css" />
    </head>
    <body>
    
        <xsl:variable name="testCount" select="sum(testsuite/@tests)"/>
        <xsl:variable name="errorCount" select="sum(testsuite/@errors)"/>
        <xsl:variable name="failureCount" select="sum(testsuite/@failures)"/>
        <xsl:variable name="timeCount" select="sum(testsuite/@time)"/>
        <xsl:variable name="successRate" select="($testCount - $failureCount - $errorCount) div $testCount"/>
        <xsl:variable name="successCount" select="($testCount - $failureCount - $errorCount)"/>            
    
        <div id="report">
            <div class="grailslogo"></div>
        
            <hgroup class="clearfix">
	            <h1><xsl:value-of select="$TITLE"/></h1>
	        
	            <p class="intro">
	                Executed <xsl:value-of select="$testCount" /> tests, <xsl:value-of select="$errorCount" /> errors and <xsl:value-of select="$failureCount" /> failures.
	            </p>
            </hgroup>
            
            
            <xsl:for-each select="./testsuite[not(./@package = preceding-sibling::testsuite/@package)]">
		        <xsl:call-template name="packages.overview">
		            <xsl:with-param name="packageName" select="@package"/>
		        </xsl:call-template>
		    </xsl:for-each>
        
        </div>
                    
    </body>
</html>
</xsl:template>


<!-- A list of all packages and their test cases -->
<xsl:template name="packages.overview">
    <xsl:param name="packageName" />
    
    <xsl:variable name="sumTime" select="sum(/testsuites/testsuite[@package = $packageName]/@time)"/>
    <xsl:variable name="testCount" select="sum(/testsuites/testsuite[@package = $packageName]/@tests)"/>
    <xsl:variable name="errorCount" select="sum(/testsuites/testsuite[@package = $packageName]/@errors)"/>
    <xsl:variable name="failureCount" select="sum(/testsuites/testsuite[@package = $packageName]/@failures)"/>
    <xsl:variable name="successCount" select="$testCount - $errorCount - $failureCount"/>
    
    <xsl:variable name="cssclass">
        <xsl:choose>
            <xsl:when test="$failureCount &gt; 0 and $errorCount = 0">failure</xsl:when>
            <xsl:when test="$errorCount &gt; 0">error</xsl:when>
            <xsl:otherwise>success</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- sum(testsuite/@tests) -->
    
    <div>
        <xsl:attribute name="class">testsuite <xsl:value-of select="$cssclass" /></xsl:attribute>
        
	    <header>
            <h2><xsl:value-of select="$packageName" /></h2>
            <h3>
                Tests: <xsl:value-of select="$testCount" />, 
                errors: <xsl:value-of select="$errorCount" />,
                failures: <xsl:value-of select="$failureCount" />.
                Executed in <xsl:value-of select="$sumTime" /> seconds.
            </h3>
        </header>
	    
	    <ul class="clearfix">
            <xsl:for-each select="/testsuites/testsuite[@package = $packageName]">
                <xsl:variable name="testcaseCssClass">
	                <xsl:choose>
	                    <xsl:when test="count(testcase/error) &gt; 0">error</xsl:when>
	                    <xsl:when test="count(testcase/failure) &gt; 0">failure</xsl:when>
	                    <xsl:otherwise>success</xsl:otherwise>
	                </xsl:choose>
                </xsl:variable>
            
                <li>   
	                <xsl:attribute name="class">packagelink <xsl:value-of select="$testcaseCssClass" /></xsl:attribute>
		        
		            <a>
		                <xsl:variable name="package.name" select="@package"/>
		                
                        <xsl:attribute name="href">
                            <xsl:if test="not($package.name='')">
                                <xsl:value-of select="translate($package.name,'.','/')"/><xsl:text>/</xsl:text>
                            </xsl:if><xsl:value-of select="@id"/>_<xsl:value-of select="@name"/><xsl:text>.html</xsl:text>
                        </xsl:attribute>		  
                        
                        <xsl:attribute name="title"><xsl:value-of select="@tests" /> tests executed in <xsl:value-of select="@time" /> seconds.</xsl:attribute>             
		            
                        <span><xsl:attribute name="class">icon <xsl:value-of select="$testcaseCssClass" /></xsl:attribute></span>
                        <xsl:value-of select="@name" />
		            </a>
	            </li>
		    </xsl:for-each>
        </ul>
    </div>
</xsl:template>


<!-- Writes the test summary -->
<xsl:template match="testsuite" mode="summary">
    <xsl:variable name="cssclass">
        <xsl:choose>
            <xsl:when test="@failures &gt; 0 and @errors = 0">failure</xsl:when>
            <xsl:when test="@errors &gt; 0">error</xsl:when>
            <xsl:otherwise>success</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <div>
        <xsl:attribute name="class">testsuite <xsl:value-of select="$cssclass" /></xsl:attribute>
        
        <header>
            <h2><xsl:value-of select="@name" /></h2>
            <h3>Executed in <xsl:value-of select="@time" /> sec, <xsl:value-of select="@errors" /> errors, <xsl:value-of select="@failures" /> failures and <xsl:value-of select="@tests - @errors - @failures" /> successes.</h3>
        </header>
        
        <xsl:apply-templates select="testcase" mode="tableline">
        </xsl:apply-templates>
        
        <footer class="clearfix output">
            <div class="sysout">
                <h2>Standard output</h2>
                <pre><xsl:value-of select="system-out" /></pre>
            </div>
            <div class="syserr">
                <h2>System error</h2>
                <pre><xsl:value-of select="system-err" /></pre>
            </div>
        </footer>
    </div>
</xsl:template>

<!-- Test method -->
<xsl:template match="testcase" mode="tableline">
    <xsl:variable name="cssclass">
        <xsl:choose>
            <xsl:when test="count(error) &gt; 0">error</xsl:when>
            <xsl:when test="count(failure) &gt; 0">failure</xsl:when>
            <xsl:otherwise>success</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <div>
        <xsl:attribute name="class">testcase clearfix <xsl:value-of select="$cssclass" /></xsl:attribute>
        
        <div class="metadata">
            <p>
                <span>
	               <xsl:attribute name="class">icon <xsl:value-of select="$cssclass" /></xsl:attribute>
	            </span>
                <b>
                    <xsl:attribute name="class">testname <xsl:value-of select="$cssclass" /></xsl:attribute>
                    <xsl:value-of select="@name" />
                </b>
            </p>
                
            <p>Executed in <xsl:value-of select="@time" /> seconds.</p>           
        </div>
        <div class="details">
            <xsl:apply-templates select="failure" mode="testcase.failure" />
            <xsl:apply-templates select="error" mode="testcase.error" />            
        </div>
    </div>
</xsl:template>

<!-- Test failure -->
<xsl:template match="failure" mode="testcase.failure">
	<div class="failure">
	    <p><b class="errorMessage failure"><xsl:value-of select="@message" /></b></p>
	    <pre><xsl:value-of select="." /></pre>
    </div>
</xsl:template>

<!-- Test error -->
<xsl:template match="error" mode="testcase.error">
	<div class="error">
	    <p><b class="errorMessage error"><xsl:value-of select="@message" /></b></p>
	    <pre><xsl:value-of select="." /></pre>
	</div>
</xsl:template>

<!-- this is the stylesheet css to use for nearly everything -->
<xsl:template name="stylesheet.css">
/*@font-face {
  font-family: 'Droid Sans Mono';
  font-style: normal;
  font-weight: normal;
  src: local('Droid Sans Mono'), local('DroidSansMono'), url('http://themes.googleusercontent.com/font?kit=ns-m2xQYezAtqh7ai59hJYW_AySPyikQrZReizgrnuw') format('truetype');
}*/

#report {
    -moz-border-radius: 8px;
    -webkit-border-radius: 8px;
    border-radius: 8px;
    
    -moz-box-shadow: 0 0 8px #F5F5F5;
    -webkit-box-shadow: 0 0 8px #F5F5F5;
    box-shadow: 0 0 8px #F5F5F5;
    
    background-color: white;
    margin: 10px auto;
    max-width: 1200px;
    padding: 10px 15px;
    width: 70%;
}

.testsuite {
    -moz-border-radius: 5px;
    -webkit-border-radius: 5px;
    border-radius: 5px;
    
    -moz-box-shadow: 0 0 4px #F8F8F8;
    -webkit-box-shadow: 0 0 4px #F8F8F8;
    box-shadow: 0 0 4px #F8F8F8;
    
    background: -moz-linear-gradient(center top , #F7F7F7, #FEFEFE);
    background: -webkit-linear-gradient(center top , #F7F7F7, #FEFEFE);
    background: linear-gradient(center top , #F7F7F7, #FEFEFE);
    
    border: 1px solid #EEEEEE;
    margin: 20px 0;
    text-align: left;
    width: 100%;
}

.testsuite header {
    color: white;
    padding: 5px 7px;
    text-shadow: 0 0 4px rgba(0, 0, 0, 0.2);
}

.testsuite.error header {
    -moz-border-radius: 5px 5px 0 0;
    -webkit-border-radius: 5px 5px 0 0;    
    border-radius: 5px 5px 0 0;
    
    -moz-box-shadow: 0 0 13px rgba(255, 255, 255, 0.3) inset;
    -webkit-box-shadow: 0 0 13px rgba(255, 255, 255, 0.3) inset;
    box-shadow: 0 0 13px rgba(255, 255, 255, 0.3) inset;
    
    background: -moz-linear-gradient(center top , #BE5959, #A94D36);
    background: -webkit-gradient(linear, left top, left bottom, from(#BE5959), to(#A94D36));
    background: linear-gradient(center top , #BE5959, #A94D36);
    
    border-bottom: 1px solid #BE5B5B;
}

.testsuite.failure header {
    -moz-border-radius: 5px 5px 0 0;
    -webkit-border-radius: 5px 5px 0 0;    
    border-radius: 5px 5px 0 0;
    
    -moz-box-shadow: 0 0 13px rgba(255, 255, 255, 0.3) inset;
    -webkit-box-shadow: 0 0 13px rgba(255, 255, 255, 0.3) inset;
    box-shadow: 0 0 13px rgba(255, 255, 255, 0.3) inset;
    
    background: -moz-linear-gradient(center top , #EFB77E, #E69814);
    background: -webkit-gradient(linear, left top, left bottom, from(#EFB77E), to(#E69814));
    background: linear-gradient(center top , #EFB77E, #E69814);
    
    border-bottom: 1px solid #CD912B;
}

.testsuite.success header {
    -moz-border-radius: 5px 5px 0 0;
    -webkit-border-radius: 5px 5px 0 0;
    border-radius: 5px 5px 0 0;
    
    -moz-box-shadow: 0 0 13px rgba(255, 255, 255, 0.3) inset;
    -webkit-box-shadow: 0 0 13px rgba(255, 255, 255, 0.3) inset;
    box-shadow: 0 0 13px rgba(255, 255, 255, 0.3) inset;
    
    background: -moz-linear-gradient(center top , #A6CC3B, #CBD53B);
    background: -webkit-gradient(linear, left top, left bottom, from(#A6CC3B), to(#CBD53B));
    background: linear-gradient(center top , #A6CC3B, #CBD53B);
    
    border-bottom: 1px solid #C4D5B6;
}

.packagelink {
    border: 1px solid transparent;
    float: left;
    font-size: 1.1em;
    list-style: none outside none;
    padding: 2px 7px;
    margin: 3px;
}

.packagelink:hover {
    -moz-border-radius: 3px 3px 3px 3px;
    background-color: #f9f9f9;
    border: 1px solid #ddd;
}

.packagelink a {
    color: blue;
    text-decoration: none;
    display: inline-block;
}

.packagelink.failure a {
    color: #FB6C00 !important;
    font-weight: bold;
}

.packagelink.error a {
    color: #DD0707 !important;
    font-weight: bold;
}

.packagelink.success a {
    color: #344804 !important;
}

.testsuite header {
    font-size: 1.3em;
}

.testsuite header h2, h3 {
    margin: 0;
    padding: 0;
}

.testsuite header h3 {
    font-size: 0.8em;
}

.testsuite .name {
    width: 50%;
}

.testsuite .time {
    width: 10%;
}

.testsuite .testcase {
    padding: 5px 0;
}

.testcase.failure .testname {
    color: #AA0E0E;
}

.testsuite .testcase:nth-of-type(2n) {
    background-color: #F4F4F4;
    border-bottom: 1px solid #EEEEEE;
    border-top: 1px solid #EEEEEE;
}

.testcase .metadata {
    float: left;
    width: 30%;
}

.metadata .testname {
    font-size: 1em;
    font-weight: bold;
}

.testname.failure {
    color: #FB6C00 !important;
}

p {
    padding: 4px;
}

.testcase .details {
    float: left;
    width: 69%;
}

footer.output {
    -moz-border-radius: 0 0 5px 5px;
    -webkit-border-radius: 0 0 5px 5px;
    border-radius: 0 0 5px 5px;
    
    background: -moz-linear-gradient(center top , #F8F8F8, #F2F2F2);
    background: -webkit-gradient(linear, left top, left bottom, from(#F8F8F8), to(#F2F2F2));
    background: linear-gradient(center top , #F8F8F8, #F2F2F2);
    
    border-top: 1px solid #EEEEEE;
    margin-top: 10px;
}

footer.output h2 {
    padding: 5px 0 0 5px;
}

footer.output .sysout, .syserr {
    float: left;
    width: 50%;
}

footer.output pre {
    margin: 5px;
}

.errorMessage {
    color: #AA0E0E;
    font-size: 1em;
    font-weight: bold;
}

.errorMessage.failure  {
    color: #FB6C00 !important;
}

body {
    background-color: #F8F8F8;
    color: #333333;
    font: 85% helvetica,sans-serif;
}
p.intro {
    font-size: 1.5em;
}

h1 {
    font-size: 2.5em;
}

a {
    color: #1A4491;
    text-decoration: none;
}

a:hover {
}

pre {
    -moz-border-radius: 5px;
    -webkit-border-radius: 5px;
    border-radius: 5px;
    
    background-color: #FFFFFF;
    border: 1px solid #DEDEDE;
    font-family: 'Monaco','Droid Sans Mono',monospace;
    font-size: 0.9em;
}

.grailslogo {
    background-image: url("data:image/png;base64,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");
    float: left;
    height: 66px;
    margin: 0 10px 5px 0;
    width: 63px;
}

/* icons 
  - - - - */

.icon {
    width: 16px;
    height: 16px;
    margin: 6px 4px 0;
    display: inline-block;
}

.icon.failure {
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAcpJREFUeNpi3FvPwoAHMEPpv+gSTg2/wTQTPs2MjMx/QBjJIAyAz4AKMS0/BjHtQDCbVAPkmNm4WxSdyhkUHYoYQGyQGCkG5MvbFDCwcfECMTeDvHUuSKyIWANs2Hkli6SNoxh+fzzK8PvDQQYZowgGTkGFfKCcKzEGZCo5VTMw/v/BcHxGGsPxWXkM//+9Y1ByLAPLETIgmV/WNEpMzY7h59uNcMGfr9cxCCsaMfDLmIBCNA2fAZnKTpUMf77fYPj/5xNC9O9Xhr/frjGouJQxAKN1JnK0IhtQLa7lZ8wjLMLw6+02BoY/H+ES//9+AbpiPQOXAD+DpEEYSKgRJscITYnSzGxcT0yS1jIw/TzJ8OfLJZAUSCsQ/WH4/x+Y6v79YmDmUmFg5g9kODUvnOHPj49KwNR4H+aCfDnzVAZWtr/AUD8EtPEzGJ9evY7h9JpNQC98Awbkd4Y/n88zMDF/Y5CzSAHrgbkAGG3ih03iFzD8fD4RaOEXoCgjkgv+Q7LCf0h2YGTiYuCUq2Y4sziZ4fv7Rz4s4GizLwTq+cbAIZnMQAz4/+8jg7JTGcOVtTmZIAOmX98CTupRDKSBrSC9jP/BTiQfAAQYAMjEmRhwR6odAAAAAElFTkSuQmCC");
}
.icon.error {
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAcJJREFUeNqkUz1PAkEQfStggjESejU0GozlGqn8SGywkYIYY0IsaLCwIBTQUN5fMLGm8S8QSWwslVAYjAlUBEJDhCgWwp3nzN6eHqIVl8zN7rx5b+dm9oRt25jlmcOMj59f10JAkPcBcXIGWdECyqYn6TfGdZ9S9d4K4gQYx4WCtJzE+G/sKJudwpQABUGnGSf5vKzX60jmctL8SYzz+iCdls1mEzuplMIsLSC4iSUh1ClUlpHIZGStVkM0GsVNqVRlIJZIyG63i1AohMdKpUrZRQqXz4j7LWA7VSiR/WRSNhsNRRgOh+i02wgGg3hrtRSZelLmI6cExs7nKJGVtTX50uupMn0+H157PUWmZpYDXLoWUFPo6MC87jivx4MBFtxOWZYS11VipNdT98DWDVsPh2XQNLFIMdc4xpg9OZ3JMdIpRowSXVKt36+yuXvGxn+N0XS+3zj0kG+JSPEi261H5FCLmN9lUyNWyZ+Qag54eA6Hbfa8j1A88g+2qrlqCkKIZdovbAG7m8D5E3B5D9xR7IPsk/u7DextABd14OrBwd6J23YFligQ0IPwXE7lbedXUAPya5yHMiLuq5j1d/4SYAAj3NATBGE4PgAAAABJRU5ErkJggg==");
}
.icon.success {
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAAZiS0dEAP8A/wD/oL2nkwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9sDCQsRAj8H3ssAAAIkSURBVDjLpZNPSFRRFMZ/971RpySdLOgvKmUxRKXZP9qIq3pQi0ih5xQUQiZBEbQVbPEg2gjuImgVwrSoRUQGQrYQDBKJmNKF1RQ6jE3O6Fg647y5p8W8RiWQwA8OBy73/PgO371KRFiPDNYpH4B6UAU+BQoQwBUoN8BUhVsKMBS2kagBngJd4fzWV2In1nCwqGHJK1cI6UTA1PTesdqPmhrnkvpp/fcKNjOlouk5bfmP/16co/NMW712cYorrKWQSio03fUnaN6Wbto5b0zn+t8NjYvm7ioHtkpaNskRWyUtoGA9I2iXzppqWoIVDbWZkin9OjI0kYzTG9ZbXhQBtqQs5eLcbr18RLk4tqQs7/xcxUZu7N9j7I3Nvmdw+OPneJS+sLv5ETlZjlG5ONdbLh6eWfhkdJy/0KBcnDaZu1nqo/tQI/vSv7RvfJxvPyZ5brjcIy8FhysAXQ8fP/mArloaXXhmtobqDiqXK3WNBFMuZdEvTCWiDIqmq49AYfJlppCwiKB6Kgnl0hbgnL3lPzAWy2zYsR1iMViMkoiPMqQN2sMllbMMZIvDIuIBLD9Um4RqFizROMEQwXkf5blJZhNvGNEGV8ODZVMMZFcltAxQ3ourNbFP5i21C6eyid3pt0zor1wLDxtjfNf/RLwSYACbgABQcayWU3XNdET6uR+ZJgJkgYzXs8ASkBMR+QtQQBng97rp/QrtletVfkXXRcB69AcDTAOk3AI32gAAAABJRU5ErkJggg==");
}


</xsl:template>




<!--
    transform string like a.b.c to ../../../
    @param path the path to transform into a descending directory path
-->
<xsl:template name="path">
    <xsl:param name="path"/>
    <xsl:if test="contains($path,'.')">
        <xsl:text>../</xsl:text>
        <xsl:call-template name="path">
            <xsl:with-param name="path"><xsl:value-of select="substring-after($path,'.')"/></xsl:with-param>
        </xsl:call-template>
    </xsl:if>
    <xsl:if test="not(contains($path,'.')) and not($path = '')">
        <xsl:text>../</xsl:text>
    </xsl:if>
</xsl:template>


<!-- create the link to the stylesheet based on the package name -->
<xsl:template name="create.stylesheet.link">
    <xsl:param name="package.name"/>
    <link rel="stylesheet" type="text/css" title="Style"><xsl:attribute name="href"><xsl:if test="not($package.name = 'unnamed package')"><xsl:call-template name="path"><xsl:with-param name="path" select="$package.name"/></xsl:call-template></xsl:if>boilerplate.css</xsl:attribute></link>
    <link rel="stylesheet" type="text/css" title="Style"><xsl:attribute name="href"><xsl:if test="not($package.name = 'unnamed package')"><xsl:call-template name="path"><xsl:with-param name="path" select="$package.name"/></xsl:call-template></xsl:if>stylesheet.css</xsl:attribute></link>
</xsl:template>

<!-- create the link to the home page wrapped around the grails logo -->
<xsl:template name="create.logo.link">
    <xsl:param name="package.name"/>
    <a title="Home"><xsl:attribute name="href"><xsl:if test="not($package.name = 'unnamed package')"><xsl:call-template name="path"><xsl:with-param name="path" select="$package.name"/></xsl:call-template></xsl:if>index.html</xsl:attribute><div class="grailslogo"></div></a>
</xsl:template>

<xsl:template match="testcase" mode="print.test">
    <xsl:param name="show.class" select="''"/>
    <tr valign="top">
        <xsl:attribute name="class">
            <xsl:choose>
                <xsl:when test="error">Error</xsl:when>
                <xsl:when test="failure">Failure</xsl:when>
                <xsl:otherwise>TableRowColor</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <!-- Handle empty packages -->
        <xsl:variable name="package.path">
            <xsl:if test="../@package != ''"><xsl:value-of select="concat(translate(../@package,'.','/'), '/')"/></xsl:if>
        </xsl:variable>
	<xsl:variable name="class.href">
	    <xsl:value-of select="concat($package.path, ../@id, '_', ../@name, '.html')"/>
	</xsl:variable>
	<xsl:if test="boolean($show.class)">
	    <td><a href="{$class.href}"><xsl:value-of select="../@name"/></a></td>
	</xsl:if>
        <td>
	    <a name="{@name}"/>
	    <xsl:choose>
		<xsl:when test="boolean($show.class)">
		    <a href="{concat($class.href, '#', @name)}"><xsl:value-of select="@name"/></a>
		</xsl:when>
		<xsl:otherwise>
		    <xsl:value-of select="@name"/>
		</xsl:otherwise>
	    </xsl:choose>
	</td>
        <xsl:choose>
            <xsl:when test="failure">
                <td>Failure</td>
                <td><xsl:apply-templates select="failure"/></td>
            </xsl:when>
            <xsl:when test="error">
                <td>Error</td>
                <td><xsl:apply-templates select="error"/></td>
            </xsl:when>
            <xsl:otherwise>
                <td>Success</td>
                <td></td>
            </xsl:otherwise>
        </xsl:choose>
        <td>
            <xsl:call-template name="display-time">
                <xsl:with-param name="value" select="@time"/>
            </xsl:call-template>
        </td>
    </tr>
</xsl:template>



<!--
    template that will convert a carriage return into a br tag
    @param word the text from which to convert CR to BR tag
-->
<xsl:template name="br-replace">
    <xsl:param name="word"/>
    <xsl:value-of disable-output-escaping="yes" select='stringutils:replace(string($word),"&#xA;","&lt;br/>")'/>
</xsl:template>

<xsl:template name="display-time">
    <xsl:param name="value"/>
    <xsl:value-of select="format-number($value,'0.000')"/>
</xsl:template>

<xsl:template name="display-percent">
    <xsl:param name="value"/>
    <xsl:value-of select="format-number($value,'0.00%')"/>
</xsl:template>




<!-- HTML5 ✰ Boilerplate -->
<xsl:template name="boilerplate.css">
html, body, div, span, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
abbr, address, cite, code, del, dfn, em, img, ins, kbd, q, samp,
small, strong, sub, sup, var, b, i, dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, figcaption, figure,
footer, header, hgroup, menu, nav, section, summary,
time, mark, audio, video {
  margin: 0;
  padding: 0;
  border: 0;
  font-size: 100%;
  font: inherit;
  vertical-align: baseline;
}

article, aside, details, figcaption, figure,
footer, header, hgroup, menu, nav, section {
  display: block;
}

blockquote, q { quotes: none; }
blockquote:before, blockquote:after,
q:before, q:after { content: ''; content: none; }
ins { background-color: #ff9; color: #000; text-decoration: none; }
mark { background-color: #ff9; color: #000; font-style: italic; font-weight: bold; }
del { text-decoration: line-through; }
abbr[title], dfn[title] { border-bottom: 1px dotted; cursor: help; }
table { border-collapse: collapse; border-spacing: 0; }
hr { display: block; height: 1px; border: 0; border-top: 1px solid #ccc; margin: 1em 0; padding: 0; }
input, select { vertical-align: middle; }

body { font:13px/1.231 sans-serif; *font-size:small; } 
select, input, textarea, button { font:99% sans-serif; }
pre, code, kbd, samp { font-family: monospace, sans-serif; }

html { overflow-y: scroll; }
a:hover, a:active { outline: none; }
ul, ol {  }
ol { list-style-type: decimal; }
nav ul, nav li { margin: 0; list-style:none; list-style-image: none; }
small { font-size: 85%; }
strong, th { font-weight: bold; }
td { vertical-align: top; }

sub, sup { font-size: 75%; line-height: 0; position: relative; }
sup { top: -0.5em; }
sub { bottom: -0.25em; }

pre { white-space: pre; white-space: pre-wrap; word-wrap: break-word; padding: 15px; }
textarea { overflow: auto; }
.ie6 legend, .ie7 legend { margin-left: -7px; } 
input[type="radio"] { vertical-align: text-bottom; }
input[type="checkbox"] { vertical-align: bottom; }
.ie7 input[type="checkbox"] { vertical-align: baseline; }
.ie6 input { vertical-align: text-bottom; }
label, input[type="button"], input[type="submit"], input[type="image"], button { cursor: pointer; }
button, input, select, textarea { margin: 0; }
input:valid, textarea:valid   {  }
input:invalid, textarea:invalid { border-radius: 1px; -moz-box-shadow: 0px 0px 5px red; -webkit-box-shadow: 0px 0px 5px red; box-shadow: 0px 0px 5px red; }
.no-boxshadow input:invalid, .no-boxshadow textarea:invalid { background-color: #f0dddd; }

::-moz-selection{ background: #FF5E99; color:#fff; text-shadow: none; }
::selection { background:#FF5E99; color:#fff; text-shadow: none; }
a:link { -webkit-tap-highlight-color: #FF5E99; }

button {  width: auto; overflow: visible; }
.ie7 img { -ms-interpolation-mode: bicubic; }

body, select, input, textarea {  color: #444; }
h1, h2, h3, h4, h5, h6 { font-weight: bold; }
a, a:active, a:visited { color: #2C3545; }
a:hover { color: #036; }


/**
 * Primary styles
 *
 * Author: 
 */
.ir { display: block; text-indent: -999em; overflow: hidden; background-repeat: no-repeat; text-align: left; direction: ltr; }
.hidden { display: none; visibility: hidden; }
.visuallyhidden { border: 0; clip: rect(0 0 0 0); height: 1px; margin: -1px; overflow: hidden; padding: 0; position: absolute; width: 1px; }
.visuallyhidden.focusable:active,
.visuallyhidden.focusable:focus { clip: auto; height: auto; margin: 0; overflow: visible; position: static; width: auto; }
.invisible { visibility: hidden; }
.clearfix:before, .clearfix:after { content: "\0020"; display: block; height: 0; overflow: hidden; }
.clearfix:after { clear: both; }
.clearfix { zoom: 1; }


@media print {
  * { background: transparent !important; color: black !important; text-shadow: none !important; filter:none !important;
  -ms-filter: none !important; } 
  a, a:visited { color: #444 !important; text-decoration: underline; }
  a[href]:after { content: " (" attr(href) ")"; }
  abbr[title]:after { content: " (" attr(title) ")"; }
  .ir a:after, a[href^="javascript:"]:after, a[href^="#"]:after { content: ""; }  
  pre, blockquote { border: 1px solid #999; page-break-inside: avoid; }
  thead { display: table-header-group; }
  tr, img { page-break-inside: avoid; }
  @page { margin: 0.5cm; }
  p, h2, h3 { orphans: 3; widows: 3; }
  h2, h3{ page-break-after: avoid; }
}
</xsl:template>



</xsl:stylesheet>
