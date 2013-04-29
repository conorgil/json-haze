<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="xs" version="2.0"
    xmlns:util="urn:json-haze:util"
    xmlns:js="urn:json-haze">

    <xsl:output method="text"/>

    <!--
        prints:
        {
            schema1,
            schema2,
            lastSchema
        }
    -->
    <xsl:template match="js:schemaContainer">
        <xsl:call-template name="startObject"/>
        <xsl:call-template name="printListOfStuff">
            <xsl:with-param name="listOfStuff" select="*"/>
        </xsl:call-template>
        <xsl:call-template name="endObject"/>
    </xsl:template>

    <!--
        prints:
        "string(@name)": {
            "required": "true/false",
            "title": "the short description in title",
            "other field": "other field value",
            "last field": "last field value"
        }
    -->
    <xsl:template match="js:schema">
        <xsl:value-of select="util:surroundWithQuotes(@name)"/>
        <xsl:call-template name="seperator"/>
        <xsl:call-template name="anonymousSchemaTemplate"/>
    </xsl:template>

    <xsl:template match="js:anonymousSchema">
        <xsl:call-template name="anonymousSchemaTemplate"/>
    </xsl:template>

    <xsl:template name="anonymousSchemaTemplate">
        <xsl:call-template name="startObject"/>
        <xsl:call-template name="printListOfStuff">
            <xsl:with-param name="listOfStuff" select="@js:* except @js:name | *"/>
        </xsl:call-template>
        <xsl:call-template name="endObject"/>
    </xsl:template>

    <!-- 
        Matches simple types and prints its attributes and child values as JSON.
    
        Example:
        <number default="5"
        divisibleBy="5"
        exclusiveMaximum="true"
        exclusiveMinimum="true"
        maximum="20"
        minimum="10"/>
        
        PRINTS:
        
        "type":"number",
        "default":"5",
        "divisibleBy":"5",
        "exclusiveMaximum":"true",
        "exclusiveMinimum":"true",
        "maximum":"20",
        "minimum":"10"
    -->
    <xsl:template match="js:string | 
        js:number | 
        js:integer | 
        js:boolean | 
        js:any | 
        js:null | 
        js:object">
        <!-- print type and comma if there is additional content -->
        <xsl:value-of select="util:printPropertyAndValue('type', name())"/>
        <xsl:if test="count(@js:* | js:*) > 0">
            <xsl:call-template name="comma"/>
            <xsl:call-template name="printListOfStuff">
                <xsl:with-param name="listOfStuff" select="@* | *"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="js:properties |
        js:patternProperties |
        js:array">
        <xsl:value-of select="util:surroundWithQuotes(name())"/>
        <xsl:call-template name="seperator"/>
        <xsl:call-template name="startObject"/>
        <xsl:call-template name="printListOfStuff">
            <xsl:with-param name="listOfStuff" select="@js:* | js:*"/>
        </xsl:call-template>
        <xsl:call-template name="endObject"/>
    </xsl:template>

    <xsl:template match="js:additionalProperties[not(child::js:false)] |
        js:additionalItems[not(child::js:false)]">
        <xsl:value-of select="util:surroundWithQuotes(name())"/>
        <xsl:call-template name="seperator"/>
        <xsl:call-template name="printListOfStuff">
            <xsl:with-param name="listOfStuff" select="@* | *"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="js:additionalProperties[child::js:false] |
        js:additionalItems[child::js:false]">
        <xsl:value-of select="util:surroundWithQuotes(name())"/>
        <xsl:call-template name="seperator"/>
        <xsl:value-of select="'false'"/>
    </xsl:template>

    <xsl:template match="js:singleItemType">
        <xsl:value-of select="util:surroundWithQuotes('items')"/>
        <xsl:call-template name="seperator"/>
        <xsl:call-template name="printListOfStuff">
            <xsl:with-param name="listOfStuff" select="*"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="js:tupleTyping">
        <xsl:value-of select="util:surroundWithQuotes('items')"/>
        <xsl:call-template name="seperator"/>
        <xsl:call-template name="startArray"/>
        <xsl:for-each select="js:anonymousSchema">
            <xsl:apply-templates select="current()"/>
            <xsl:if test="position() != last()">
                <xsl:call-template name="comma"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:call-template name="endArray"/>
        
        <xsl:if test="child::js:additionalItems">
            <xsl:call-template name="comma"/>
            <xsl:apply-templates select="js:additionalItems"/>
        </xsl:if>
    </xsl:template>

    <!--
        changes description into:
        "description": "text()"
    -->
    <xsl:template match="js:description">
        <xsl:value-of select="util:printPropertyAndValue(name(), text())"/>
    </xsl:template>

    <!-- prints out enum as a JSON array -->
    <xsl:template match="js:enum">
        <xsl:value-of select="util:surroundWithQuotes(name())"/>
        <xsl:call-template name="seperator"/>
        <xsl:call-template name="startArray"/>
        <xsl:for-each select="js:option">
            <xsl:value-of select="util:surroundWithQuotes(current()/@value)"/>
            <xsl:if test="position() != last()">
                <xsl:call-template name="comma"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:call-template name="endArray"/>
    </xsl:template>

    <!-- UTIL FUNCTIONS -->

    <!-- 
        given a list of stuff, calls applyTemplates on each thing, 
        and prints a comma unless its the last thing in the list -->
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
        Prints attributes like: "attribute name": "attribute value"
        
        Example, given
            @title="description here"
        this template prints
            "title": "description here"
    -->
    <xsl:template match="@*">
        <xsl:value-of select="util:printPropertyAndValue(name(), .)"/>
    </xsl:template>

    <!--
        printPropertyAndValue("foo", "bar") 
        returns
        "foo": "bar"
    -->
    <xsl:function name="util:printPropertyAndValue">
        <xsl:param name="property"/>
        <xsl:param name="value"/>
        <xsl:value-of select="util:surroundWithQuotes($property)"/>
        <xsl:call-template name="seperator"/>
        <xsl:value-of select="util:surroundWithQuotes($value)"/>
    </xsl:function>

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
