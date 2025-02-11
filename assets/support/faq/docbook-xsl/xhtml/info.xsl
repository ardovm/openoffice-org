<?xml version="1.0" encoding="US-ASCII"?>
<!--This file was created automatically by html2xhtml-->
<!--from the HTML stylesheets. Do not edit this file.-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- ********************************************************************
     $Id: info.xsl,v 1.1 2003/08/21 00:15:49 cphennessy Exp $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://nwalsh.com/docbook/xsl/ for copyright
     and other information.

     ******************************************************************** -->

<!-- These templates define the "default behavior" for info
     elements.  Even if you don't process the *info wrappers,
     some of these elements are needed because the elements are
     processed from named templates that are called with modes.
     Since modes aren't sticky, these rules apply. 
     (TODO: clarify this comment) -->

<!-- ==================================================================== -->
<!-- called from named templates in a given mode -->

<xsl:template match="corpauthor">
  <span xmlns="http://www.w3.org/1999/xhtml" class="{name(.)}">
    <xsl:apply-templates/>
  </span>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="jobtitle">
  <span xmlns="http://www.w3.org/1999/xhtml" class="{name(.)}">
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="orgname">
  <span xmlns="http://www.w3.org/1999/xhtml" class="{name(.)}">
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="orgdiv">
  <span xmlns="http://www.w3.org/1999/xhtml" class="{name(.)}">
    <xsl:apply-templates/>
  </span>
</xsl:template>

<!-- ==================================================================== -->

</xsl:stylesheet>
