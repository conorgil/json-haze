<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	exclude-result-prefixes="xs" version="2.0" xmlns:util="urn:json-haze:util"
	xmlns:js="urn:json-haze">

	<xsl:output method="text"/>

	<xsl:template match="js:schema">
		<xsl:call-template name="startObject"/>
		<!-- specifically does not include js:schema/@* -->
		<xsl:call-template name="printListOfStuff">
			<xsl:with-param name="listOfStuff" select="@required | @title | js:*"/>
		</xsl:call-template>
		<xsl:call-template name="endObject"/>
	</xsl:template>

	<xsl:template match="js:property">
		<xsl:value-of select="util:printPropertyName(@name)"/>
		<xsl:call-template name="printAttrAndChildContent"/>
	</xsl:template>

	<xsl:template match="js:array |
		js:properties |
		js:patternProperties">
		<xsl:value-of select="util:printPropertyName(name())"/>
		<xsl:call-template name="startObject"/>
		<xsl:call-template name="printAttrAndChildContent"/>
		<xsl:call-template name="endObject"/>
	</xsl:template>
	
	<xsl:template match="@* | js:description">
		<xsl:value-of select="util:printPropertyNameAndValue(name(), .)"/>
	</xsl:template>
	
	<!-- 
        prints:
        "type": "name()"
        
        if attribtues or child elements, prints a comma followed by that content 
    -->
	<xsl:template
		match="js:string | 
        js:number | 
        js:integer | 
        js:boolean | 
        js:any | 
        js:null | 
        js:object">
		<xsl:value-of select="util:printPropertyNameAndValue('type', name())"/>
		<xsl:if test="count(@* | js:*) > 0">
			<xsl:call-template name="comma"/>
			<xsl:call-template name="printAttrAndChildContent"/>
		</xsl:if>
	</xsl:template>

	<xsl:template
		match="js:additionalProperties[not(child::js:false)] |
      js:additionalItems[not(child::js:false)]">
		<xsl:value-of select="util:printPropertyName(name())"/>
		<xsl:call-template name="printAttrAndChildContent"/>
	</xsl:template>

	<xsl:template
		match="js:additionalProperties[child::js:false] |
        js:additionalItems[child::js:false]">
		<xsl:value-of select="util:printPropertyName(name())"/>
		<xsl:value-of select="'false'"/>
	</xsl:template>

	<xsl:template match="js:singleItemType">
		<xsl:value-of select="util:printPropertyName('items')"/>
		<xsl:call-template name="printAttrAndChildContent"/>
	</xsl:template>

	<!--
		prints:
		"items": [schema1, schema2, etc],
		"additionalItems": content of additionalItems
		
	-->
	<xsl:template match="js:tupleTyping">
		<xsl:value-of select="util:printPropertyName('items')"/>
		<xsl:call-template name="startArray"/>
		<xsl:call-template name="printListOfStuff">
			<xsl:with-param name="listOfStuff" select="js:* except js:additionalItems"/>
		</xsl:call-template>
		<xsl:call-template name="endArray"/>

		<xsl:if test="child::js:additionalItems">
			<xsl:call-template name="comma"/>
			<xsl:apply-templates select="js:additionalItems"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="js:schemaArray">
		<xsl:call-template name="printAttrAndChildContent"/>
	</xsl:template>

	<!-- prints:
			"enum": [option1, option2, option3, etc]
	-->
	<xsl:template match="js:enum">
		<xsl:value-of select="util:printPropertyName(name())"/>
		<xsl:call-template name="startArray"/>
		<xsl:for-each select="js:option">
			<xsl:value-of select="util:surroundWithQuotes(current()/@value)"/>
			<xsl:if test="position() != last()">
				<xsl:call-template name="comma"/>
			</xsl:if>
		</xsl:for-each>
		<xsl:call-template name="endArray"/>
	</xsl:template>

	<!--
		applies-templates to the contents of the referenced file
	-->
	<xsl:template match="js:schemaReference[@file]">
		<xsl:apply-templates select="document(@file)/js:schema"/>
	</xsl:template>


	<!--======================== UTIL FUNCTIONS =======================-->

	<!-- 
        given a list of stuff, calls applyTemplates on each thing
        and prints a comma unless its the last thing in the list
	-->
	<xsl:template name="printListOfStuff">
		<xsl:param name="listOfStuff" as="node()+"/>
		<xsl:for-each select="$listOfStuff">
			<xsl:apply-templates select="current()"/>
			<xsl:if test="position() != last()">
				<xsl:call-template name="comma"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- 
        surroundWithQuotes("foo")
        returns
        "foo"
    -->
	<xsl:function name="util:surroundWithQuotes">
		<xsl:param name="property"/>
		<xsl:call-template name="startProperty"/>
		<xsl:value-of select="normalize-space(string($property))"/>
		<xsl:call-template name="endProperty"/>
	</xsl:function>
	
	<!--
        printProperty("foo") 
        returns
        "foo":
    -->
	<xsl:function name="util:printPropertyName">
		<xsl:param name="property"/>
		<xsl:value-of select="util:surroundWithQuotes($property)"/>
		<xsl:call-template name="seperator"/>
	</xsl:function>

	<!--
        printPropertyAndValue("foo", "bar") 
        returns
        "foo": "bar"
    -->
	<xsl:function name="util:printPropertyNameAndValue">
		<xsl:param name="property"/>
		<xsl:param name="value"/>
		<xsl:value-of select="util:printPropertyName($property)"/>
		<xsl:value-of select="util:surroundWithQuotes($value)"/>
	</xsl:function>

	<!-- call this instead of apply-templates because this will print the correct
		commas -->
	<xsl:template name="printAttrAndChildContent">
		<xsl:call-template name="printListOfStuff">
			<xsl:with-param name="listOfStuff" select="@* except @name | js:*"/>
		</xsl:call-template>
	</xsl:template>

	<!-- CONSTANTS -->
	<xsl:template name="startProperty">
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template name="endProperty">
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template name="seperator">
		<xsl:text>:</xsl:text>
	</xsl:template>

	<xsl:template name="startObject">
		<xsl:text>{</xsl:text>
	</xsl:template>

	<xsl:template name="endObject">
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template name="startArray">
		<xsl:text>[</xsl:text>
	</xsl:template>

	<xsl:template name="endArray">
		<xsl:text>]</xsl:text>
	</xsl:template>

	<xsl:template name="comma">
		<xsl:text>,</xsl:text>
	</xsl:template>
</xsl:stylesheet>
