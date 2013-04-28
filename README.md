JSON-Haze
===============

Provides an XML schema for describing JSON schemas and an XSLT to transform instances into JSON schemas.

I could not find any JSON schema editors, so I built this to help me create JSON schemas by hand. This allows
you to use an existing mature XML editor (oXygen, XML Spy, etc) to define an XML instance describing your JSON 
schema. Then, the XSLT can be applied to the XML instance to generate the JSON schema.

There is a strong focus on documentation because there will be an XSLT (eventually) to 
automatically generate documentation for the JSON schema.

The JSON schema seems outrageously immature at this point, so I take the liberty of forcing the use of some 
mechanisms and preventing the use of other mechanisms:

    - dependencies: skipped over this field entirely
        
    - enum: only supports enum of string, number, integer 
            the spec allows enum of arrays and objects too, but that is hard
            
    - format: not sure how most of those values make any sense except for string values. 
          How can an integer be a color?
          How can a boolean be an email?
          JSON spec is stupid... :(
          I only support format on strings right now because it makes sense
      
    - default: can objects/arrays have default values too?
          currently only supports default on string, number, integer, boolean
          
    - disallow: currently unsupported
      
    - extends: currently unsupported
    
    - $ref: currently unsupported

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