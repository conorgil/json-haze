<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="xs" version="2.0">
    
    <xsl:output method="text"/>
    
    <xsl:template match="schemaContainer">
        <xsl:call-template name="startObject"/>
        <xsl:apply-templates/>
        <xsl:call-template name="endObject"/>
    </xsl:template>

    <xsl:template match="schema">
        <xsl:call-template name="printProperty">
            <xsl:with-param name="property" select="@name"/>
        </xsl:call-template>
        
        <xsl:call-template name="seperator"/>
        <xsl:call-template name="startObject"/>
        <xsl:call-template name="newline"/>
        <xsl:call-template name="printSimple">
            <xsl:with-param name="attributes" select="@* except @name"/>
        </xsl:call-template>
        <xsl:call-template name="comma"/>
        <xsl:apply-templates select="*"/>
        <xsl:call-template name="endObject"/>
    </xsl:template>

<!-- given a list of stuff, calls applyTemplates on each thing, 
        prints a newline, 
        and prints a comma unless its the last thing in the list -->
    <xsl:template name="printSimple">
        <xsl:param name="attributes" as="node()+"/>
        <xsl:for-each select="@* except @name">
            <xsl:apply-templates select="current()"/>
            <xsl:if test="position() != last()">
                <xsl:call-template name="comma"/>
            </xsl:if>
            <xsl:call-template name="newline"/>
        </xsl:for-each> 
    </xsl:template>

    <!-- These templates should not put a comma at the end because we don't
        know if there are more values after this.
        The calling function should put a comma if there are more values
        to match on.
    -->
    <xsl:template match="@*"> 
        <xsl:call-template name="printProperty">
            <xsl:with-param name="property" select="name(.)"/>
        </xsl:call-template>
        <xsl:call-template name="seperator"/>
        <xsl:call-template name="printProperty">
            <xsl:with-param name="property" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="string | number | any">
        <xsl:call-template name="printProperty">
            <xsl:with-param name="property" select="'type'"/>
        </xsl:call-template> 
        <xsl:call-template name="seperator"/>
        <xsl:call-template name="printProperty">
            <xsl:with-param name="property" select="name()"/>
        </xsl:call-template>
        <xsl:if test="count(@* | node()) > 0">
            <xsl:call-template name="comma"/>
        </xsl:if>
        <xsl:call-template name="newline"/>
        
        <xsl:call-template name="printSimple">
            <xsl:with-param name="attributes" select="@* | node()"/>
        </xsl:call-template>
    </xsl:template>

    



    <!-- UTIL FUNCTIONS -->
    <xsl:template name="printProperty">
        <xsl:param name="property"/>
        <xsl:call-template name="startProperty"/>
        <xsl:value-of select="$property"/>
        <xsl:call-template name="endProperty"/>
    </xsl:template>
    
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
