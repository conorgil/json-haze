JSON-Haze
===============

# JSON-Haze

JSON-Haze is basically JSON schema for XML developers. The provided XSD lets 
developers create XML instances that describe a JSON schema and then generate
the JSON schema from the XML instance using XSLT. The XSD is an interpretation
of the [JSON schema v3](http://tools.ietf.org/html/draft-zyp-json-schema-03)
that provides structure, only lets you use fields where they are appropriate,
and defines what each field means. Using the XSD with a decent XML editor will
provide auto-complete and validation functionality as well.

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
<schemaContainer>
 <schema name="fieldOne" required="true">
   <number/>
 </schema>
 <schema name="fieldTwo" required="false">
   <string/>
 </schema>
</schemaContainer>
```

generates the JSON schema:

```javascript
{
    "fieldOne": {
        "required": "true",
        "type": "number"
    },
    "fieldTwo": {
        "required": "false",
        "type": "string"
    }
}
```

# Brief explanations/definitions
* `schemaContainer` is the root element. It basically holds one or more schemas and
wraps them in the outer `{` and `}` in the JSON output.
* `schema` is a schema with a name. The name of a `schema` is the left hand side
of a property.
```javascript
{
  "schema/@name": {
    //schema content
  }
}
```
* `anonymousSchema` is the same as `schema`, but does not have a name. In other
words, it is not assigned to a property. No left hand side. Just 
```javascript
{
  //schema content
}
```

# Status
Definitely still in early development.

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

Notes and questions:
 
Based on [section 5.19](http://tools.ietf.org/html/draft-zyp-json-schema-03#section-5.19)
 of the JSON v3 schema, enum is a first class simple type. In other words, 
 you can do

```xml
<schema>
	<enum>
		<option value="value one"/>
		<option value="value two"/>
	<enum>
</schema>
```

## TODOs
* give XSD a namespace
* create tiny command line tool for compiling the XML into JSON schema
* command line tool can fix the formatting? JSLint?
* create stylesheet to generate documentation!!
* rename schema to namedSchema? Will this make anonymousSchema clearer?
