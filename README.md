JSON-Haze
===============

JSON-Haze is basically JSON schema for XML developers. The provided XSD lets 
developers create XML instances that describe a JSON schema and then generate
the JSON schema from the XML instance using XSLT. The XSD is an interpretation
of the [JSON schema v3](http://tools.ietf.org/html/draft-zyp-json-schema-03)
that provides structure, only lets you use fields where they are appropriate,
and defines what each field means. Using the XSD with a decent XML editor will
provide auto-complete and validation functionality as well.

JSON schema v3 defines a large list of 29 attributes, all of which are optional
and can be used with any other attribute even if that combination does not make
sense. It is typical for an attribute defintion to restrict when the attribute
applies by saying "when the instance value is an X, this applies". For example:

```
5.10.  maximum

   This attribute defines the maximum value of the instance property
   when the type of the instance value is a number.
```

It doesn't make sense to ever use the maximum attribute when you know your
instance value is a string. JSON-Haze forces you to select a type for each field
and only allows the attributes that make sense for that type. This will help
developers quickly build schemas instead of considering which options are
valid in the scope of any particular field.

# How to use
1. Create an XML instance that is valid against `json-haze.xsd`
2. Apply `bin/xml-to-json.xsl` to the XML instance
3. Happily use your generated JSON schema

You can apply the XSLT to the XML instance using an XML editor with XSLT support,
or a command line XSLT processor, such as
[Saxon](http://sourceforge.net/projects/saxon/files/Saxon-HE/).

The `bin/` directory contains a simple script that will run the stylesheet
for you using the bundled Saxon 9.5 jar and run the output through a python
command to pretty print the JSON.

Put `bin/` on your path and chmod the `haze` script so you can execute it.

`haze <input XML instance filename> <output filename>`

# Example
Simple example XML instance describing two fields:
```xml
<schema xmlns="urn:json-haze">
	<object>
		<properties>
			<property name="fieldOne">
				<schema required="true">
					<number minimum="0" maximum="100"/>
				</schema>
			</property>
			<property name="fieldTwo">
				<schema>
					<string minLength="5" maxLength="10"/>
				</schema>
			</property>
		</properties>
		<additionalProperties>
			<false/>
		</additionalProperties>
	</object>
</schema>
```

generates the JSON schema:

```javascript
{
    "type": "object",
    "properties": {
        "fieldOne": {
            "type": "number",
            "minimum": "0",
            "maximum": "100"
        },
        "fieldTwo": {
            "type": "string",
            "minLength": "5",
            "maxLength": "10"
        }
    },
    "additionalProperties": false
}
```

# Brief explanations/definitions
* `<schema>` represents a JSON schema:

```javascript
{
  //schema content
}
```

* `<property name="fieldName">` respresents the left hand side of a JSON property:

```javascript
{
  "fieldName": a JSON schema definition
}
```

The XSD contains documentation taken from the JSON schema spec for each element
to help developers understand how the element functions in a JSON schema.


You can reference a `<schema>` defined in another file by using 
```javascript
{
  <schemaReference ref="relative/path/to/file"/>
}
```

# Status
Still in early development.

* Fully supported types
 * string, integer, number, boolean, object, array
* Partially supported types/fields
 * enum
      * currently, only supports enum of string, number, integer. Need to add support
 for enums of arrays and objects
 * format
     * currently, only supported for strings. I am not sure how most of
 those values make any sense except for string values. 
     * How can an integer be a color?
     * How can a boolean be an email?
 * default
     * currently, only supports default on string, number, integer, boolean
     * can objects/arrays have default values too? 
* Not currently supported at all
    * unionType
    * dependencies
    * disallow
    * extends
    * $ref
    * $schema 

## TODOs
* create stylesheet to generate documentation!!
so people can have a place to define common schemas for using with $ref (schema v4 specifically defines 'definitions' for this purpose)
`* schema likely needs to allow customProperties as children

