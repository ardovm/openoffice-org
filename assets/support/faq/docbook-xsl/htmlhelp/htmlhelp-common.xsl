<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                xmlns:exsl="http://exslt.org/common"
                xmlns:set="http://exslt.org/sets"
                xmlns:h="urn:x-hex"
		version="1.0"
                exclude-result-prefixes="doc exsl set h">

<!-- ********************************************************************
     $Id: htmlhelp-common.xsl,v 1.1 2003/08/21 00:15:58 cphennessy Exp $
     ******************************************************************** -->

<!-- ==================================================================== -->
<!-- Customizations of standard HTML stylesheet parameters -->

<xsl:param name="suppress.navigation" select="1"/>

<!-- ==================================================================== -->

<xsl:variable name="generate.index" select="//indexterm[1]"/>

<!-- ==================================================================== -->

<xsl:template match="/">
  <xsl:if test="$htmlhelp.only != 1">
    <xsl:choose>
      <xsl:when test="$rootid != ''">
        <xsl:choose>
          <xsl:when test="count(key('id',$rootid)) = 0">
            <xsl:message terminate="yes">
              <xsl:text>ID '</xsl:text>
              <xsl:value-of select="$rootid"/>
              <xsl:text>' not found in document.</xsl:text>
            </xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>Formatting from <xsl:value-of select="$rootid"/></xsl:message>
            <xsl:apply-templates select="key('id',$rootid)" mode="process.root"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="/" mode="process.root"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>

  <xsl:call-template name="hhp"/>
  <xsl:call-template name="hhc"/>
  <xsl:if test="($rootid = '' and //processing-instruction('dbhh')) or
                ($rootid != '' and key('id',$rootid)//processing-instruction('dbhh'))">
    <xsl:call-template name="hh-map"/>
    <xsl:call-template name="hh-alias"/>
  </xsl:if>
  <xsl:if test="$generate.index">
    <xsl:call-template name="hhk"/>
  </xsl:if>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template name="hhp">
  <xsl:call-template name="write.text.chunk">
    <xsl:with-param name="filename" select="$htmlhelp.hhp"/>
    <xsl:with-param name="method" select="'text'"/>
    <xsl:with-param name="content">
      <xsl:call-template name="hhp-main"/>
    </xsl:with-param>
    <xsl:with-param name="encoding" select="$htmlhelp.encoding"/>
  </xsl:call-template>
</xsl:template>

<!-- ==================================================================== -->
<xsl:template name="hhp-main">
<xsl:variable name="default.topic">
  <xsl:choose>
    <xsl:when test="$htmlhelp.default.topic != ''">
      <xsl:value-of select="$htmlhelp.default.topic"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="make-relative-filename">
        <xsl:with-param name="base.dir" select="$base.dir"/>
        <xsl:with-param name="base.name">
          <xsl:choose>
            <xsl:when test="$rootid != ''">
              <xsl:apply-templates select="key('id',$rootid)" mode="chunk-filename"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="/" mode="chunk-filename"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="xnavigation">
  <xsl:text>0x</xsl:text>
  <xsl:call-template name="toHex">
    <xsl:with-param name="n" select="9504 + $htmlhelp.show.menu * 65536
                                          + $htmlhelp.show.advanced.search * 131072
                                          + $htmlhelp.show.favorities * 4096"/>
  </xsl:call-template>
</xsl:variable>
<xsl:variable name="xbuttons">
  <xsl:text>0x</xsl:text>
  <xsl:call-template name="toHex">
    <xsl:with-param name="n" select="0 + $htmlhelp.button.hideshow * 2
                                       + $htmlhelp.button.back * 4
                                       + $htmlhelp.button.forward * 8
                                       + $htmlhelp.button.stop * 16
                                       + $htmlhelp.button.refresh * 32
                                       + $htmlhelp.button.home * 64
                                       + $htmlhelp.button.options * 4096
                                       + $htmlhelp.button.print * 8192
                                       + $htmlhelp.button.locate * 2048
                                       + $htmlhelp.button.jump1 * 262144
                                       + $htmlhelp.button.jump2 * 524288
                                       + $htmlhelp.button.next * 2097152
                                       + $htmlhelp.button.prev * 4194304
                                       + $htmlhelp.button.zoom * 1048576"/>
  </xsl:call-template>
</xsl:variable>
<xsl:text>[OPTIONS]
</xsl:text>
<xsl:if test="$generate.index">
<xsl:text>Auto Index=Yes
</xsl:text></xsl:if>
<xsl:if test="$htmlhelp.hhc.binary != 0">
<xsl:text>Binary TOC=Yes
</xsl:text></xsl:if>
<xsl:text>Compatibility=1.1 or later
Compiled file=</xsl:text><xsl:value-of select="$htmlhelp.chm"/><xsl:text>
Contents file=</xsl:text><xsl:value-of select="$htmlhelp.hhc"/><xsl:text>
</xsl:text>
<xsl:if test="$htmlhelp.hhp.window != ''">
<xsl:text>Default Window=</xsl:text><xsl:value-of select="$htmlhelp.hhp.window"/><xsl:text>
</xsl:text></xsl:if>
<xsl:text>Default topic=</xsl:text><xsl:value-of select="$default.topic"/>
<xsl:text>
Display compile progress=Yes
Full-text search=Yes
</xsl:text>
<xsl:if test="$generate.index">
<xsl:text>Index file=</xsl:text><xsl:value-of select="$htmlhelp.hhk"/><xsl:text>
</xsl:text></xsl:if>
<xsl:text>Language=</xsl:text>
<xsl:for-each select="*">   <!-- Change context from / to root element -->
  <xsl:call-template name="gentext.template">
    <xsl:with-param name="context" select="'htmlhelp'"/>
    <xsl:with-param name="name" select="'langcode'"/>
  </xsl:call-template>
</xsl:for-each>
<xsl:text>
Title=</xsl:text>
  <xsl:choose>
    <xsl:when test="$htmlhelp.title = ''">
      <xsl:choose>
        <xsl:when test="$rootid != ''">
          <xsl:apply-templates select="key('id',$rootid)" mode="title.markup"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="/*" mode="title.markup"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$htmlhelp.title"/>
    </xsl:otherwise>
  </xsl:choose>

<xsl:if test="$htmlhelp.hhp.window != ''">
  <xsl:text>

[WINDOWS]
</xsl:text>
<xsl:value-of select="$htmlhelp.hhp.window"/>
<xsl:text>=,"</xsl:text><xsl:value-of select="$htmlhelp.hhc"/>
<xsl:text>",</xsl:text>
<xsl:if test="$generate.index">
  <xsl:text>"</xsl:text>
  <xsl:value-of select="$htmlhelp.hhk"/>
  <xsl:text>"</xsl:text>
</xsl:if>
<xsl:text>,"</xsl:text>
<xsl:value-of select="$default.topic"/>
<xsl:text>",</xsl:text>
<xsl:text>"</xsl:text>
<xsl:choose>
  <xsl:when test="$htmlhelp.button.home != 0">
    <xsl:value-of select="$htmlhelp.button.home.url"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="$default.topic"/>
  </xsl:otherwise>
</xsl:choose>
<xsl:text>"</xsl:text>
<xsl:text>,</xsl:text>
<xsl:if test="$htmlhelp.button.jump1 != 0">
  <xsl:text>"</xsl:text>
  <xsl:value-of select="$htmlhelp.button.jump1.url"/>
  <xsl:text>"</xsl:text>
</xsl:if>
<xsl:text>,</xsl:text>
<xsl:if test="$htmlhelp.button.jump1 != 0">
  <xsl:text>"</xsl:text>
  <xsl:value-of select="$htmlhelp.button.jump1.title"/>
  <xsl:text>"</xsl:text>
</xsl:if>
<xsl:text>,</xsl:text>
<xsl:if test="$htmlhelp.button.jump2 != 0">
  <xsl:text>"</xsl:text>
  <xsl:value-of select="$htmlhelp.button.jump2.url"/>
  <xsl:text>"</xsl:text>
</xsl:if>
<xsl:text>,</xsl:text>
<xsl:if test="$htmlhelp.button.jump2 != 0">
  <xsl:text>"</xsl:text>
  <xsl:value-of select="$htmlhelp.button.jump2.title"/>
  <xsl:text>"</xsl:text>
</xsl:if>
<xsl:text>,</xsl:text>
<xsl:value-of select="$xnavigation"/>
<xsl:text>,,</xsl:text>
<xsl:value-of select="$xbuttons"/>
<xsl:text>,,,,,,,,0
</xsl:text>
</xsl:if>

<xsl:text>

[FILES]
</xsl:text>

<xsl:choose>
  <xsl:when test="$rootid != ''">
    <xsl:apply-templates select="key('id',$rootid)" mode="enumerate-files"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates select="/" mode="enumerate-files"/>
  </xsl:otherwise>
</xsl:choose>

<xsl:if test="$htmlhelp.enumerate.images">
  <xsl:variable name="imagelist">
    <xsl:choose>
      <xsl:when test="$rootid != ''">
        <xsl:apply-templates select="key('id',$rootid)" mode="enumerate-images"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="/" mode="enumerate-images"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="function-available('exsl:node-set') and function-available('set:distinct')">
      <xsl:for-each select="set:distinct(exsl:node-set($imagelist)/filename)">
        <xsl:value-of select="."/>
        <xsl:text>&#10;</xsl:text>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$imagelist"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:if>

<xsl:if test="($htmlhelp.force.map.and.alias != 0) or 
              ($rootid = '' and //processing-instruction('dbhh')) or
              ($rootid != '' and key('id',$rootid)//processing-instruction('dbhh'))">
  <xsl:text>
[ALIAS]
#include </xsl:text><xsl:value-of select="$htmlhelp.alias.file"/><xsl:text>

[MAP]
#include </xsl:text><xsl:value-of select="$htmlhelp.map.file"/><xsl:text>
</xsl:text>
</xsl:if>

<xsl:value-of select="$htmlhelp.hhp.tail"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="graphic|inlinegraphic[@format!='linespecific']" mode="enumerate-images">
  <xsl:call-template name="write.filename.enumerate-images">
    <xsl:with-param name="filename">
      <xsl:call-template name="mediaobject.filename.enumerate-images">
        <xsl:with-param name="object" select="."/>
      </xsl:call-template>  
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="mediaobject|inlinemediaobject" mode="enumerate-images">
  <xsl:call-template name="select.mediaobject.enumerate-images"/>
</xsl:template>

<xsl:template name="select.mediaobject.enumerate-images" mode="enumerate-images">
  <xsl:param name="olist"
             select="imageobject|imageobjectco
                     |videoobject|audioobject|textobject"/>
  <xsl:param name="count">1</xsl:param>

  <xsl:if test="$count &lt;= count($olist)">
    <xsl:variable name="object" select="$olist[position()=$count]"/>

    <xsl:variable name="useobject">
      <xsl:choose>
	<!-- The phrase is never used -->
        <xsl:when test="name($object)='textobject' and $object/phrase">
          <xsl:text>0</xsl:text>
        </xsl:when>
	<!-- The first textobject is a reasonable fallback (but not for image in HH) -->
        <xsl:when test="name($object)='textobject'">
          <xsl:text>0</xsl:text>
        </xsl:when>
	<!-- If there's only one object, use it -->
	<xsl:when test="$count = 1 and count($olist) = 1">
	  <xsl:text>1</xsl:text>
	</xsl:when>
	<!-- Otherwise, see if this one is a useable graphic -->
        <xsl:otherwise>
          <xsl:choose>
            <!-- peek inside imageobjectco to simplify the test -->
            <xsl:when test="local-name($object) = 'imageobjectco'">
              <xsl:call-template name="is.acceptable.mediaobject">
                <xsl:with-param name="object" select="$object/imageobject"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="is.acceptable.mediaobject">
                <xsl:with-param name="object" select="$object"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$useobject='1' and $object[not(*/@format='linespecific')]">
        <xsl:call-template name="write.filename.enumerate-images">
          <xsl:with-param name="filename">
            <xsl:call-template name="mediaobject.filename.enumerate-images">
              <xsl:with-param name="object" select="$object"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="select.mediaobject.enumerate-images">
          <xsl:with-param name="olist" select="$olist"/>
          <xsl:with-param name="count" select="$count + 1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template name="mediaobject.filename.enumerate-images" mode="enumerate-images">
  <xsl:param name="object"/>

  <xsl:variable name="urifilename">
    <xsl:call-template name="mediaobject.filename">
      <xsl:with-param name="object" select="$object"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="filename">
    <xsl:choose>
      <xsl:when test="starts-with($urifilename, 'file:/')">
	<xsl:value-of select="substring-after($urifilename, 'file:/')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$urifilename"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:value-of select="translate($filename, '/', '\')"/>

</xsl:template>

<xsl:template match="text()" mode="enumerate-images">
</xsl:template>

<xsl:template name="write.filename.enumerate-images" mode="enumerate-images">
  <xsl:param name="filename"/>
  <xsl:choose>
    <xsl:when test="function-available('exsl:node-set') and function-available('set:distinct')">
      <filename><xsl:value-of select="$filename"/></filename>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$filename"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->

<!-- Following templates are not nice. It is because MS help compiler is unable
     to process correct HTML files. We must generate following weird
     stuff instead. -->

<xsl:template name="hhc">
  <xsl:call-template name="write.text.chunk">
    <xsl:with-param name="filename" select="$htmlhelp.hhc"/>
    <xsl:with-param name="method" select="'text'"/>
    <xsl:with-param name="content">
      <xsl:call-template name="hhc-main"/>
    </xsl:with-param>
    <xsl:with-param name="encoding" select="$htmlhelp.encoding"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="hhc-main">
  <xsl:text disable-output-escaping="yes">&lt;HTML&gt;
&lt;HEAD&gt;
&lt;/HEAD&gt;
  &lt;BODY&gt;
</xsl:text>
  <xsl:if test="$htmlhelp.hhc.folders.instead.books != 0">
    <xsl:text disable-output-escaping="yes">&lt;OBJECT type="text/site properties"&gt;
	&lt;param name="ImageType" value="Folder"&gt;
&lt;/OBJECT&gt;
</xsl:text>
  </xsl:if>
  <xsl:if test="$htmlhelp.hhc.show.root != 0">
<xsl:text disable-output-escaping="yes">&lt;UL&gt;
</xsl:text>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="$rootid != ''">
      <xsl:apply-templates select="key('id',$rootid)" mode="hhc"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="/" mode="hhc"/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:if test="$htmlhelp.hhc.show.root != 0">
  <xsl:text disable-output-escaping="yes">&lt;/UL&gt;
</xsl:text>
  </xsl:if>
  <xsl:text disable-output-escaping="yes">&lt;/BODY&gt;
&lt;/HTML&gt;</xsl:text>
</xsl:template>

<xsl:template match="set" mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="escape-attr">
      <xsl:with-param name="value">
        <xsl:apply-templates select="." mode="title.markup"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$htmlhelp.hhc.show.root != 0">
    <xsl:text disable-output-escaping="yes">&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
      &lt;param name="Name" value="</xsl:text>
          <xsl:value-of select="normalize-space($title)"/>
      <xsl:text disable-output-escaping="yes">"&gt;
      &lt;param name="Local" value="</xsl:text>
          <xsl:call-template name="href.target.with.base.dir"/>
      <xsl:text disable-output-escaping="yes">"&gt;
    &lt;/OBJECT&gt;</xsl:text>
  </xsl:if>
  <xsl:if test="book">
    <xsl:variable name="toc.params">
      <xsl:call-template name="find.path.params">
        <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:text disable-output-escaping="yes">&lt;UL&gt;</xsl:text>
      <xsl:if test="contains($toc.params, 'toc') and $htmlhelp.hhc.show.root = 0">
        <xsl:text disable-output-escaping="yes">&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
          &lt;param name="Name" value="</xsl:text>
            <xsl:call-template name="gentext">
              <xsl:with-param name="key" select="'TableofContents'"/>
            </xsl:call-template>
          <xsl:text disable-output-escaping="yes">"&gt;
          &lt;param name="Local" value="</xsl:text>
              <xsl:call-template name="href.target.with.base.dir"/>
          <xsl:text disable-output-escaping="yes">"&gt;
        &lt;/OBJECT&gt;</xsl:text>
      </xsl:if>
      <xsl:apply-templates select="book" mode="hhc"/>
    <xsl:text disable-output-escaping="yes">&lt;/UL&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="book" mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="escape-attr">
      <xsl:with-param name="value">
        <xsl:apply-templates select="." mode="title.markup"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$htmlhelp.hhc.show.root != 0 or parent::*">
    <xsl:text disable-output-escaping="yes">&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
      &lt;param name="Name" value="</xsl:text>
          <xsl:value-of select="normalize-space($title)"/>
      <xsl:text disable-output-escaping="yes">"&gt;
      &lt;param name="Local" value="</xsl:text>
          <xsl:call-template name="href.target.with.base.dir"/>
      <xsl:text disable-output-escaping="yes">"&gt;
    &lt;/OBJECT&gt;</xsl:text>
  </xsl:if>
  <xsl:if test="part|reference|preface|chapter|appendix|bibliography|article|colophon|glossary">
    <xsl:variable name="toc.params">
      <xsl:call-template name="find.path.params">
        <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:text disable-output-escaping="yes">&lt;UL&gt;</xsl:text>
      <xsl:if test="contains($toc.params, 'toc') and $htmlhelp.hhc.show.root = 0 and not(parent::*)">
        <xsl:text disable-output-escaping="yes">&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
          &lt;param name="Name" value="</xsl:text>
            <xsl:call-template name="gentext">
              <xsl:with-param name="key" select="'TableofContents'"/>
            </xsl:call-template>
          <xsl:text disable-output-escaping="yes">"&gt;
          &lt;param name="Local" value="</xsl:text>
              <xsl:call-template name="href.target.with.base.dir"/>
          <xsl:text disable-output-escaping="yes">"&gt;
        &lt;/OBJECT&gt;</xsl:text>
      </xsl:if>
      <xsl:apply-templates select="part|reference|preface|chapter|bibliography|appendix|article|colophon|glossary"
			   mode="hhc"/>
    <xsl:text disable-output-escaping="yes">&lt;/UL&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="part|reference|preface|chapter|bibliography|appendix|article|glossary"
              mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="escape-attr">
      <xsl:with-param name="value">
        <xsl:apply-templates select="." mode="title.markup"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$htmlhelp.hhc.show.root != 0 or parent::*">
    <xsl:text disable-output-escaping="yes">&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
      &lt;param name="Name" value="</xsl:text>
          <xsl:value-of select="normalize-space($title)"/>
      <xsl:text disable-output-escaping="yes">"&gt;
      &lt;param name="Local" value="</xsl:text>
          <xsl:call-template name="href.target.with.base.dir"/>
      <xsl:text disable-output-escaping="yes">"&gt;
    &lt;/OBJECT&gt;</xsl:text>
  </xsl:if>
  <xsl:if test="reference|preface|chapter|appendix|refentry|section|sect1|bibliodiv">
    <xsl:text disable-output-escaping="yes">&lt;UL&gt;</xsl:text>
      <xsl:apply-templates
	select="reference|preface|chapter|appendix|refentry|section|sect1|bibliodiv"
	mode="hhc"/>
    <xsl:text disable-output-escaping="yes">&lt;/UL&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="section" mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="escape-attr">
      <xsl:with-param name="value">
        <xsl:apply-templates select="." mode="title.markup"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$htmlhelp.hhc.show.root != 0 or parent::*">
    <xsl:text disable-output-escaping="yes">&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
      &lt;param name="Name" value="</xsl:text>
          <xsl:value-of select="normalize-space($title)"/>
      <xsl:text disable-output-escaping="yes">"&gt;
      &lt;param name="Local" value="</xsl:text>
          <xsl:call-template name="href.target.with.base.dir"/>
      <xsl:text disable-output-escaping="yes">"&gt;
    &lt;/OBJECT&gt;</xsl:text>
  </xsl:if>
  <xsl:if test="section[count(ancestor::section) &lt; $htmlhelp.hhc.section.depth]|refentry">
    <xsl:text disable-output-escaping="yes">&lt;UL&gt;</xsl:text>
      <xsl:apply-templates select="section|refentry" mode="hhc"/>
    <xsl:text disable-output-escaping="yes">&lt;/UL&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="sect1" mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="escape-attr">
      <xsl:with-param name="value">
        <xsl:apply-templates select="." mode="title.markup"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$htmlhelp.hhc.show.root != 0 or parent::*">
    <xsl:text disable-output-escaping="yes">&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
      &lt;param name="Name" value="</xsl:text>
          <xsl:value-of select="normalize-space($title)"/>
      <xsl:text disable-output-escaping="yes">"&gt;
      &lt;param name="Local" value="</xsl:text>
          <xsl:call-template name="href.target.with.base.dir"/>
      <xsl:text disable-output-escaping="yes">"&gt;
    &lt;/OBJECT&gt;</xsl:text>
  </xsl:if>
  <xsl:if test="sect2[$htmlhelp.hhc.section.depth > 1]|refentry">
    <xsl:text disable-output-escaping="yes">&lt;UL&gt;</xsl:text>
      <xsl:apply-templates select="sect2|refentry"
			   mode="hhc"/>
    <xsl:text disable-output-escaping="yes">&lt;/UL&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="sect2" mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="escape-attr">
      <xsl:with-param name="value">
        <xsl:apply-templates select="." mode="title.markup"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$htmlhelp.hhc.show.root != 0 or parent::*">
    <xsl:text disable-output-escaping="yes">&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
      &lt;param name="Name" value="</xsl:text>
          <xsl:value-of select="normalize-space($title)"/>
      <xsl:text disable-output-escaping="yes">"&gt;
      &lt;param name="Local" value="</xsl:text>
          <xsl:call-template name="href.target.with.base.dir"/>
      <xsl:text disable-output-escaping="yes">"&gt;
    &lt;/OBJECT&gt;</xsl:text>
  </xsl:if>
  <xsl:if test="sect3[$htmlhelp.hhc.section.depth > 2]|refentry">
    <xsl:text disable-output-escaping="yes">&lt;UL&gt;</xsl:text>
      <xsl:apply-templates select="sect3|refentry"
			   mode="hhc"/>
    <xsl:text disable-output-escaping="yes">&lt;/UL&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="sect3" mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="escape-attr">
      <xsl:with-param name="value">
        <xsl:apply-templates select="." mode="title.markup"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$htmlhelp.hhc.show.root != 0 or parent::*">
    <xsl:text disable-output-escaping="yes">&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
      &lt;param name="Name" value="</xsl:text>
          <xsl:value-of select="normalize-space($title)"/>
      <xsl:text disable-output-escaping="yes">"&gt;
      &lt;param name="Local" value="</xsl:text>
          <xsl:call-template name="href.target.with.base.dir"/>
      <xsl:text disable-output-escaping="yes">"&gt;
    &lt;/OBJECT&gt;</xsl:text>
  </xsl:if>
  <xsl:if test="sect4[$htmlhelp.hhc.section.depth > 3]|refentry">
    <xsl:text disable-output-escaping="yes">&lt;UL&gt;</xsl:text>
      <xsl:apply-templates select="sect4|refentry"
			   mode="hhc"/>
    <xsl:text disable-output-escaping="yes">&lt;/UL&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="sect4" mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="escape-attr">
      <xsl:with-param name="value">
        <xsl:apply-templates select="." mode="title.markup"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$htmlhelp.hhc.show.root != 0 or parent::*">
    <xsl:text disable-output-escaping="yes">&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
      &lt;param name="Name" value="</xsl:text>
          <xsl:value-of select="normalize-space($title)"/>
      <xsl:text disable-output-escaping="yes">"&gt;
      &lt;param name="Local" value="</xsl:text>
          <xsl:call-template name="href.target.with.base.dir"/>
      <xsl:text disable-output-escaping="yes">"&gt;
    &lt;/OBJECT&gt;</xsl:text>
  </xsl:if>
  <xsl:if test="sect5[$htmlhelp.hhc.section.depth > 4]|refentry">
    <xsl:text disable-output-escaping="yes">&lt;UL&gt;</xsl:text>
      <xsl:apply-templates select="sect5|refentry"
			   mode="hhc"/>
    <xsl:text disable-output-escaping="yes">&lt;/UL&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="sect5|refentry|colophon|bibliodiv" mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="escape-attr">
      <xsl:with-param name="value">
        <xsl:apply-templates select="." mode="title.markup"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$htmlhelp.hhc.show.root != 0 or parent::*">
    <xsl:text disable-output-escaping="yes">&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
      &lt;param name="Name" value="</xsl:text>
          <xsl:value-of select="normalize-space($title)"/>
      <xsl:text disable-output-escaping="yes">"&gt;
      &lt;param name="Local" value="</xsl:text>
          <xsl:call-template name="href.target.with.base.dir"/>
      <xsl:text disable-output-escaping="yes">"&gt;
    &lt;/OBJECT&gt;</xsl:text>
  </xsl:if>
  <xsl:if test="refentry">
    <xsl:text disable-output-escaping="yes">&lt;UL&gt;</xsl:text>
      <xsl:apply-templates select="refentry"
			   mode="hhc"/>
    <xsl:text disable-output-escaping="yes">&lt;/UL&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<!-- ==================================================================== -->

<!-- no separate HTML page with index -->
<xsl:template match="index"/>   
<xsl:template match="index" mode="toc"/>

<xsl:template match="indexterm">
  <xsl:choose>
    <xsl:when test="$htmlhelp.use.hhk = 0">
  
      <xsl:variable name="primary" select="normalize-space(primary)"/>
      <xsl:variable name="secondary" select="normalize-space(secondary)"/>
      <xsl:variable name="tertiary" select="normalize-space(tertiary)"/>
      
      <xsl:variable name="text">
        <xsl:value-of select="$primary"/>
        <xsl:if test="secondary">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$secondary"/>
        </xsl:if>
        <xsl:if test="tertiary">
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$tertiary"/>
        </xsl:if>
      </xsl:variable>
      
      <xsl:if test="secondary">
        <xsl:if test="not(//indexterm[normalize-space(primary)=$primary and not(secondary)])">
          <xsl:call-template name="write.indexterm">
            <xsl:with-param name="text" select="$primary"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      
      <xsl:call-template name="write.indexterm">
        <xsl:with-param name="text" select="$text"/>
      </xsl:call-template>
      
    </xsl:when>
    <xsl:otherwise>
      <a>
        <xsl:attribute name="name">
          <xsl:call-template name="object.id"/>
        </xsl:attribute>
      </a>
    </xsl:otherwise>
    
  </xsl:choose>
</xsl:template>

<xsl:template name="write.indexterm">
  <xsl:param name="text"/>
  <OBJECT type="application/x-oleobject"
          classid="clsid:1e2a7bd0-dab9-11d0-b93a-00c04fc99f9e">
    <param name="Keyword" value="{$text}"/>
  </OBJECT>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template name="hhk">
  <xsl:call-template name="write.text.chunk">
    <xsl:with-param name="filename" select="$htmlhelp.hhk"/>
    <xsl:with-param name="method" select="'text'"/>
    <xsl:with-param name="content"><xsl:text disable-output-escaping="yes"><![CDATA[<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<HEAD>
<meta name="GENERATOR" content="Microsoft&reg; HTML Help Workshop 4.1">
<!-- Sitemap 1.0 -->
</HEAD><BODY>
<OBJECT type="text/site properties">
</OBJECT>
<UL>]]>
</xsl:text>
<xsl:if test="($htmlhelp.use.hhk != 0) and $generate.index">
  <xsl:choose>
    <xsl:when test="$rootid != ''">
      <xsl:apply-templates select="key('id',$rootid)" mode="hhk"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="/" mode="hhk"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:if>
<xsl:text disable-output-escaping="yes"><![CDATA[</UL>
</BODY></HTML>]]>
</xsl:text></xsl:with-param>
    <xsl:with-param name="encoding" select="$htmlhelp.encoding"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="indexterm[@class='endofrange']" mode="hhk"/>

<xsl:template match="indexterm" mode="hhk">
  <xsl:variable name="primary" select="normalize-space(primary)"/>
  <xsl:variable name="secondary" select="normalize-space(secondary)"/>
  <xsl:variable name="tertiary" select="normalize-space(tertiary)"/>

  <xsl:call-template name="write.indexterm.hhk">
    <xsl:with-param name="text" select="$primary"/>
    <xsl:with-param name="seealso" select="seealso"/>
  </xsl:call-template>

  <xsl:if test="secondary">
    <xsl:if test="not(//indexterm[normalize-space(primary)=$primary and not(secondary)])">
      <xsl:call-template name="write.indexterm.hhk">
        <!-- We must create fake entry when there is secondary without primary --> 
        <xsl:with-param name="text" select="$primary"/>
        <xsl:with-param name="seealso" select="$primary"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:text disable-output-escaping="yes"><![CDATA[<UL>]]>&#10;</xsl:text>
    <xsl:call-template name="write.indexterm.hhk">
      <xsl:with-param name="text" select="$secondary"/>
      <xsl:with-param name="seealso" select="secondary/seealso"/>
    </xsl:call-template>
    <xsl:if test="tertiary">
      <xsl:text disable-output-escaping="yes"><![CDATA[<UL>]]>&#10;</xsl:text>
      <xsl:call-template name="write.indexterm.hhk">
        <xsl:with-param name="text" select="$tertiary"/>
        <xsl:with-param name="seealso" select="tertiary/seealso"/>
      </xsl:call-template>
      <xsl:text disable-output-escaping="yes"><![CDATA[</UL>]]>&#10;</xsl:text>
    </xsl:if>
    <xsl:text disable-output-escaping="yes"><![CDATA[</UL>]]>&#10;</xsl:text>
  </xsl:if>

</xsl:template>

<xsl:template name="write.indexterm.hhk">
  <xsl:param name="text"/>
  <xsl:param name="seealso"/>
  <xsl:variable name="text.escaped">
    <xsl:call-template name="escape-attr">
      <xsl:with-param name="value" select="$text"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:text disable-output-escaping="yes"><![CDATA[<LI> <OBJECT type="text/sitemap">
    <param name="Name" value="]]></xsl:text><xsl:value-of select="$text.escaped"/><xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
      <xsl:if test="not(seealso)">
        <xsl:variable name="href">
          <xsl:call-template name="href.target.with.base.dir"/>
        </xsl:variable>
        <xsl:variable name="title">
          <xsl:call-template name="escape-attr">
            <xsl:with-param name="value">
              <xsl:call-template name="nearest.title">
                <xsl:with-param name="object" select=".."/>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>
        <xsl:text disable-output-escaping="yes"><![CDATA[<param name="Name" value="]]></xsl:text>
          <xsl:value-of select="$title"/>
        <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
        <xsl:text disable-output-escaping="yes"><![CDATA[<param name="Local" value="]]></xsl:text>
          <xsl:value-of select="$href"/>
        <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
      </xsl:if>
      <xsl:if test="seealso">
        <xsl:text disable-output-escaping="yes"><![CDATA[<param name="See Also" value="]]></xsl:text>
          <xsl:value-of select="$seealso"/>
        <xsl:text disable-output-escaping="yes"><![CDATA[">]]></xsl:text>
      </xsl:if>
      <xsl:text disable-output-escaping="yes"><![CDATA[ </OBJECT>]]></xsl:text>
</xsl:template>

<xsl:template match="text()" mode="hhk"/>

<xsl:template name="nearest.title">
  <xsl:param name="object"/>
  <xsl:apply-templates select="$object/ancestor-or-self::*[title][1]" mode="title.markup"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template name="hh-map">
  <xsl:call-template name="write.text.chunk">
    <xsl:with-param name="filename" select="$htmlhelp.map.file"/>
    <xsl:with-param name="method" select="'text'"/>
    <xsl:with-param name="content">
     <xsl:choose>
       <xsl:when test="$rootid != ''">
         <xsl:apply-templates select="key('id',$rootid)" mode="hh-map"/>
       </xsl:when>
       <xsl:otherwise>
         <xsl:apply-templates select="/" mode="hh-map"/>
       </xsl:otherwise>
     </xsl:choose>
    </xsl:with-param>
    <xsl:with-param name="encoding" select="$htmlhelp.encoding"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="processing-instruction('dbhh')" mode="hh-map">
  <xsl:variable name="topicname">
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis"
                      select="."/>
      <xsl:with-param name="attribute" select="'topicname'"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="topicid">
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis"
                      select="."/>
      <xsl:with-param name="attribute" select="'topicid'"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:text>#define </xsl:text>
  <xsl:value-of select="$topicname"/>
  <xsl:text>&#9;</xsl:text>
  <xsl:value-of select="$topicid"/>
  <xsl:text>&#xA;</xsl:text>
</xsl:template>

<xsl:template match="text()" mode="hh-map"/>

<!-- ==================================================================== -->

<xsl:template name="hh-alias">
  <xsl:call-template name="write.text.chunk">
    <xsl:with-param name="filename" select="$htmlhelp.alias.file"/>
    <xsl:with-param name="method" select="'text'"/>
    <xsl:with-param name="content">
     <xsl:choose>
       <xsl:when test="$rootid != ''">
         <xsl:apply-templates select="key('id',$rootid)" mode="hh-alias"/>
       </xsl:when>
       <xsl:otherwise>
         <xsl:apply-templates select="/" mode="hh-alias"/>
       </xsl:otherwise>
     </xsl:choose>
    </xsl:with-param>
    <xsl:with-param name="encoding" select="$htmlhelp.encoding"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="processing-instruction('dbhh')" mode="hh-alias">
  <xsl:variable name="topicname">
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis"
                      select="."/>
      <xsl:with-param name="attribute" select="'topicname'"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="href">
    <xsl:call-template name="href.target.with.base.dir">
      <xsl:with-param name="object" select=".."/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:value-of select="$topicname"/>
  <xsl:text>=</xsl:text>
  <xsl:value-of select="substring-before(concat($href, '#'), '#')"/>
  <xsl:text>&#xA;</xsl:text>
</xsl:template>

<xsl:template match="text()" mode="hh-alias"/>

<!-- ==================================================================== -->

<xsl:template name="href.target.with.base.dir">
  <xsl:param name="object" select="."/>
  <xsl:value-of select="$base.dir"/>
  <xsl:call-template name="href.target">
    <xsl:with-param name="object" select="$object"/>
  </xsl:call-template>
</xsl:template>

<!-- ==================================================================== -->
<!-- This code can be used to convert any number to hexadecimal format -->

  <h:hex>
    <d>0</d>
    <d>1</d>
    <d>2</d>
    <d>3</d>
    <d>4</d>
    <d>5</d>
    <d>6</d>
    <d>7</d>
    <d>8</d>
    <d>9</d>
    <d>A</d>
    <d>B</d>
    <d>C</d>
    <d>D</d>
    <d>E</d>
    <d>F</d>
  </h:hex>

  <xsl:template name="toHex">
    <xsl:param name="n" select="0"/>
    <xsl:param name="digit" select="$n mod 16"/>
    <xsl:param name="rest" select="floor($n div 16)"/>
    <xsl:if test="$rest > 0">
      <xsl:call-template name="toHex">
        <xsl:with-param name="n" select="$rest"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:value-of select="document('')//h:hex/d[$digit+1]"/>
  </xsl:template>

<!-- ==================================================================== -->
<!-- Template for escaping <, & and " in attribute values. 
     We aren't using HTML output method, so we must do this job ourselves -->

<xsl:template name="escape-attr">
  <xsl:param name="value"/>

  <xsl:variable name="amp.escaped">
    <xsl:call-template name="string.subst">
      <xsl:with-param name="string" select="$value"/>
      <xsl:with-param name="target" select="'&amp;'"/>
      <xsl:with-param name="replacement" select="'&amp;amp;'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="quot.escaped">
    <xsl:call-template name="string.subst">
      <xsl:with-param name="string" select="$amp.escaped"/>
      <xsl:with-param name="target" select="'&quot;'"/>
      <xsl:with-param name="replacement" select="'&amp;quot;'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="angle.escaped">
    <xsl:call-template name="string.subst">
      <xsl:with-param name="string" select="$quot.escaped"/>
      <xsl:with-param name="target" select="'&lt;'"/>
      <xsl:with-param name="replacement" select="'&amp;lt;'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:value-of select="$angle.escaped"/>

</xsl:template>
  

</xsl:stylesheet>
