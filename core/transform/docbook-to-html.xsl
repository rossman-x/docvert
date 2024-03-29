<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:db="http://docbook.org/ns/docbook"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"

	exclude-result-prefixes="db html xlink"
	>

	<xsl:output
		method="xml"
		version="1.0"
		encoding="UTF-8"
		indent="yes"
		doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
		omit-xml-declaration="yes"/>

	<xsl:preserve-space elements="db:para"/>

	<xsl:param name="withTableOfContents"/>

<xsl:template match="/db:book">
	<html xml:lang="en" lang="en">
		<head>
			<title>
				<xsl:choose>
					<xsl:when test="/db:book/db:preface and /db:book/db:chapter">
						<xsl:value-of select="/db:book/db:title"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="/db:book/db:preface/db:title"/>
						<xsl:value-of select="/db:book/db:chapter/db:title"/>
						<xsl:if test="/db:book/db:title and normalize-space(/db:book/db:title) != '[no title]' ">
							<xsl:if test="/db:book/db:preface/db:title or /db:book/db:chapter/db:title">
								<xsl:text> - </xsl:text>
							</xsl:if>
							<xsl:value-of select="/db:book/db:title"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</title>
		</head>
		<body>
			<xsl:apply-templates select="*[not(self::db:toc)]"/>
			<xsl:call-template name="drawFootNoteContent"/>
		</body>
	</html>
</xsl:template>


<xsl:template match="db:toc | db:abstract | db:info"/>

<xsl:template match="db:book/db:title">
	<xsl:if test="/db:book/db:preface/db:title or /db:book/db:chapter/db:title">
		<p class="pageTitle">
			<xsl:value-of select="/db:book/db:preface/db:title"/>
			<xsl:value-of select="/db:book/db:chapter/db:title"/>
			&#160;
		</p>
	</xsl:if>
	<xsl:if test="/db:book/db:title and normalize-space(/db:book/db:title) != '[no title]' ">
		<p class="documentTitle">
			<xsl:value-of select="/db:book/db:title"/>
		</p>
	</xsl:if>
</xsl:template>

<xsl:template match="db:chapter | db:preface">
	<div class="page" id="editcontent">
		<xsl:if test="$withTableOfContents">
			<xsl:apply-templates select="/db:book/db:toc"/>
		</xsl:if>
		<xsl:apply-templates/>
	</div>
</xsl:template>

<xsl:template match="db:toc">
	<div id="tableOfContents">
		<h1>Table of Contents</h1>
		<ul>
			<xsl:apply-templates select="db:tocentry"/>
		</ul>
	</div>
</xsl:template>

<xsl:template match="db:tocentry">
	<li>
		<xsl:apply-templates/>
		<xsl:apply-templates select="following-sibling::*[1][self::db:tocchap]"/>
	</li>
</xsl:template>

<xsl:template match="db:tocchap">
	<ul>
		<xsl:apply-templates/>
	</ul>
</xsl:template>


<xsl:template match="db:literallayout">
	<xsl:element name="pre">
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="db:literal[@role='additionalSpace']">
	<xsl:text>&#160;</xsl:text>
</xsl:template>

<xsl:template match="db:footnote">
	<sup class="footnote">
		<a>
			<xsl:attribute name="href">#footnote-<xsl:value-of select="@label"/></xsl:attribute>
			<xsl:attribute name="name">source-of-footnote-<xsl:value-of select="@label"/></xsl:attribute>
			<xsl:attribute name="title">Footnote <xsl:value-of select="@label"/></xsl:attribute>
			<xsl:value-of select="@label"/>
		</a>
	</sup>
</xsl:template>

<xsl:template match="db:footnote/db:para[count(preceding-sibling::db:para) = 0]" role="footnoteText">
	<xsl:variable name="footnoteLabel" select="parent::db:footnote/@label"/>
	<p>
		<a>
			<xsl:attribute name="name">footnote-<xsl:value-of select="$footnoteLabel"/></xsl:attribute>
			<xsl:attribute name="href">#source-of-footnote-<xsl:value-of select="$footnoteLabel"/></xsl:attribute>
			<xsl:attribute name="title">Back to footnote reference <xsl:value-of select="$footnoteLabel"/></xsl:attribute>
			<xsl:value-of select="$footnoteLabel"/>
		</a>:
		<xsl:apply-templates/>
	</p>
</xsl:template>

<xsl:template name="drawFootNoteContent">
	<xsl:if test="//db:footnote">
		<div id="footnotes">
			<xsl:for-each select="//db:footnote">
				<div class="footnote">
					<xsl:apply-templates role="footnoteText"/>
				</div>
			</xsl:for-each>
		</div>
	</xsl:if>
</xsl:template>

<xsl:template match="db:link">
	<xsl:element name="a">
		<xsl:attribute name="href">
			<xsl:value-of select="@xlink:href"/>
		</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="db:itemizedlist | db:list">
	<ul><xsl:apply-templates/></ul>
</xsl:template>

<xsl:template match="db:orderedlist">
	<ol><xsl:apply-templates/></ol>
</xsl:template>

<xsl:template match="db:listitem">
	<li>
		<xsl:choose>
			<xsl:when test="count(*)=1 and count(db:para)=1"><xsl:apply-templates select="*/child::node()"/></xsl:when>
			<xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
		</xsl:choose>
	</li>
</xsl:template>

<xsl:template match="db:para">
	<p>
		<xsl:if test="contains(@role, 'dc.')">
			<xsl:attribute name="class">
				<xsl:value-of select="translate(@role, '.', '-')"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</p>
</xsl:template>

<xsl:template match="db:chapter/db:title">
	<h1>
		<xsl:if test="@id">
			<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</h1>
</xsl:template>

<xsl:template match="db:preface/db:title">
	<h1 class="documentTitle">
		<xsl:if test="@id">
			<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</h1>
</xsl:template>

<xsl:template match="db:sect1 | db:sect2 | db:sect3 | db:sect4 | db:sect5 | db:sect6">
	<div class="{local-name()}">
		<xsl:apply-templates/>
	</div>
</xsl:template>

<xsl:template match="db:sect1/db:title">
	<h2>
		<xsl:if test="@id">
			<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
			<a name="{@id}"></a>
		</xsl:if>
		<xsl:apply-templates/>
	</h2>
</xsl:template>

<xsl:template match="db:sect2/db:title">
	<h3>
		<xsl:if test="@id">
			<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
			<a name="{@id}"></a>
		</xsl:if>
		<xsl:apply-templates/>
	</h3>
</xsl:template>

<xsl:template match="db:sect3/db:title">
	<h4>
		<xsl:if test="@id">
			<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
			<a name="{@id}"></a>
		</xsl:if>
		<xsl:apply-templates/>
	</h4>
</xsl:template>

<xsl:template match="db:sect4/db:title">
	<h5>
		<xsl:if test="@id">
			<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
			<a name="{@id}"></a>
		</xsl:if>
		<xsl:apply-templates/>
	</h5>
</xsl:template>

<xsl:template match="db:sect5/db:title | db:sect6/db:title | db:sect7/db:title | db:sect8/db:title | db:sect9/db:title">
	<h6>
		<xsl:if test="@id">
			<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
			<a name="{@id}"></a>
		</xsl:if>
		<xsl:apply-templates/>
	</h6>
</xsl:template>

<xsl:template match="db:table">
	<table>
		<xsl:if test="@db:id">
			<xsl:attribute name="id"><xsl:value-of select="@db:id"/></xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</table>
</xsl:template>

<xsl:template match="db:table/db:title">
	<xsl:if test="normalize-space(.) or *">
		<caption>
			<xsl:apply-templates/>
		</caption>
	</xsl:if>
</xsl:template>

<xsl:template match="db:row"><tr><xsl:apply-templates/></tr></xsl:template>

<xsl:template match="db:thead"><thead><xsl:apply-templates/></thead></xsl:template>

<xsl:template match="db:tfoot"><tfoot><xsl:apply-templates/></tfoot></xsl:template>

<xsl:template match="db:tbody"><tbody><xsl:apply-templates/></tbody></xsl:template>

<xsl:template match="db:row">
	<tr>
		<xsl:apply-templates/>
	</tr>
</xsl:template>

<xsl:template match="db:entry">
	<xsl:choose>
		<xsl:when test="ancestor::db:thead or @role='heading' ">
			<th>
				<xsl:if test="@html:colspan">
					<xsl:attribute name="colspan"><xsl:value-of select="@html:colspan"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="@html:rowspan">
					<xsl:attribute name="rowspan"><xsl:value-of select="@html:rowspan"/></xsl:attribute>
				</xsl:if>
				<xsl:apply-templates/>
			</th>
		</xsl:when>
		<xsl:otherwise>
			<td>
				<xsl:if test="@html:colspan">
					<xsl:attribute name="colspan"><xsl:value-of select="@html:colspan"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="@html:rowspan">
					<xsl:attribute name="rowspan"><xsl:value-of select="@html:rowspan"/></xsl:attribute>
				</xsl:if>
				<xsl:apply-templates/>
			</td>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="db:mediaobject">
	<xsl:element name="img">
		<xsl:attribute name="src">
			<xsl:value-of select="descendant::db:imagedata/@fileref"/>
		</xsl:attribute>
		<xsl:attribute name="alt">
			<xsl:value-of select="descendant::db:caption"/>
		</xsl:attribute>
		<xsl:if test="normalize-space(descendant::db:imagedata/@width)">
			<xsl:attribute name="width"><xsl:value-of select="descendant::db:imagedata/@width"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="normalize-space(descendant::db:imagedata/@height)">
			<xsl:attribute name="height"><xsl:value-of select="descendant::db:imagedata/@height"/></xsl:attribute>
		</xsl:if>
	</xsl:element>
</xsl:template>

<xsl:template match="db:literal[@role='linebreak']"><br/></xsl:template>

<xsl:template match="db:GUIMenu">
	<xsl:if test="normalize-space(.)">
		<div class="menu" id="{@id}">
			<xsl:if test="@id = 'pagesMenu' or @id = 'nextPreviousMenu' or @id = 'pageInternalMenu' ">
				<h1>
					<xsl:choose>
						<xsl:when test="@id = 'pagesMenu' ">Table of Contents</xsl:when>
						<xsl:when test="@id = 'nextPreviousMenu' ">Page Navigation</xsl:when>
						<xsl:when test="@id = 'pageInternalMenu' ">Within this page</xsl:when>
					</xsl:choose>
				</h1>
			</xsl:if>
			<ul>
				<xsl:apply-templates/>
			</ul>
		</div>
	</xsl:if>
</xsl:template>

<xsl:template match="db:emphasis">
	<xsl:choose>
		<xsl:when test="@role = 'bold' ">
			<xsl:element name="b">
				<xsl:apply-templates/>
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:element name="i">
				<xsl:apply-templates/>
			</xsl:element>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="db:GUIMenuItem">
	<li>
		<xsl:apply-templates/>
		<xsl:if test="not(normalize-space(descendant::text()))">[no title]</xsl:if>
	</li>
</xsl:template>

<xsl:template match="db:GUISubMenu">
	<li>
		<xsl:apply-templates/>
	</li>
</xsl:template>

<xsl:template match="db:inlinegraphic">
	<img src="{@fileref}" alt="{normalize-space(.)}"/>
</xsl:template>

<xsl:template match="html:div">
	<img src="{@fileref}" alt="{normalize-space(.)}"/>
</xsl:template>


</xsl:stylesheet>
