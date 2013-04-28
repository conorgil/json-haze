<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="xs" version="2.0"
    xmlns:util="urn:json-haze:util">

    <xsl:output method="text"/>

    <!--
        prints:
        {
            schema1,
            schema2,
            lastSchema
        }
    -->
    <xsl:template match="schemaContainer">
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
    <xsl:template match="schema">
        <xsl:value-of select="util:surroundWithQuotes(@name)"/>
        <xsl:call-template name="seperator"/>
        <xsl:call-template name="anonymousSchemaTemplate"/>
    </xsl:template>

    <xsl:template match="anonymousSchema">
        <xsl:call-template name="anonymousSchemaTemplate"/>
    </xsl:template>

    <xsl:template name="anonymousSchemaTemplate">
        <xsl:call-template name="startObject"/>
        <xsl:call-template name="newline"/>
        <xsl:call-template name="printListOfStuff">
            <xsl:with-param name="listOfStuff" select="@* except @name | *"/>
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
    <xsl:template match="string | number | integer | boolean | any | null | object">
        <!-- print type and comma if there is additional content -->
        <xsl:value-of select="util:printPropertyAndValue('type', name())"/>
        <xsl:if test="count(@* | *) > 0">
            <xsl:call-template name="comma"/>
            <xsl:call-template name="printListOfStuff">
                <xsl:with-param name="listOfStuff" select="@* | *"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:call-template name="newline"/>
    </xsl:template>

    <xsl:template match="properties | 
        additionalProperties[not(child::false)] |
        additionalItems[not(child::false)] |
        patternProperties |
        array">
        <xsl:value-of select="util:surroundWithQuotes(name())"/>
        <xsl:call-template name="seperator"/>
        <xsl:call-template name="startObject"/>
        <xsl:call-template name="printListOfStuff">
            <xsl:with-param name="listOfStuff" select="@* | *"/>
        </xsl:call-template>
        <xsl:call-template name="endObject"/>
    </xsl:template>

    <xsl:template match="additionalProperties[child::false] |
        additionalItems[child::false]">
        <xsl:value-of select="util:surroundWithQuotes(name())"/>
        <xsl:call-template name="seperator"/>
        <xsl:value-of select="'false'"/>
    </xsl:template>

    <xsl:template match="singleItemType">
        <xsl:value-of select="util:surroundWithQuotes('items')"/>
        <xsl:call-template name="seperator"/>
        <xsl:call-template name="printListOfStuff">
            <xsl:with-param name="listOfStuff" select="*"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="tupleTyping">
        <xsl:value-of select="util:surroundWithQuotes('items')"/>
        <xsl:call-template name="seperator"/>
        <xsl:call-template name="startArray"/>
        <xsl:for-each select="*">
            <xsl:apply-templates select="current()"/>
            <xsl:if test="position() != last()">
                <xsl:call-template name="comma"/>
                <xsl:call-template name="newline"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:call-template name="endArray"/>
    </xsl:template>

    <!--
        changes description into:
        "description": "text()"
    -->
    <xsl:template match="description">
        <xsl:value-of select="util:printPropertyAndValue(name(), text())"/>
    </xsl:template>

    <!-- prints out enum as a JSON array -->
    <xsl:template match="enum">
        <xsl:value-of select="util:surroundWithQuotes(name())"/>
        <xsl:call-template name="seperator"/>
        <xsl:call-template name="startArray"/>
        <xsl:for-each select="option">
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
        prints a newline, 
        and prints a comma unless its the last thing in the list -->
    <xsl:template name="printListOfStuff">
        <xsl:param name="listOfStuff" as="node()+"/>
        <xsl:for-each select="$listOfStuff">
            <xsl:apply-templates select="current()"/>
            <xsl:if test="position() != last()">
                <xsl:call-template name="comma"/>
                <xsl:call-template name="newline"/>
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

    <xsl:template name="newline">
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
