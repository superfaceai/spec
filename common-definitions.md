# Common Definitions

## Identifier

Identifier :: /[_A-Za-z][_0-9A-Za-z]*/

## URL Value

URLValue :: `"` URL `"`

## String Value

StringValue :: `"` StringCharacter* `"`

StringCharacter ::
  - SourceCharacter but not `"` or \
  - \ EscapedCharacter

EscapedCharacter :: one of `"` \ `/` n r t

## Integer Value

IntegerValue :: /[0-9]+/
