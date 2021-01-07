# Common Definitions

## Identifier

Identifier :: /[_A-Za-z][_0-9A-Za-z]*/

## Profile Identifier

ProfileIdentifier : ProfileScope? ProfileName

ProfileScope : DocumentNameIdentifier `/`

ProfileName : DocumentNameIdentifier

DocumentNameIdentifier :: /[a-z][a-z0-9_-]*/

Identifier of a profile regardless its version.

```example
character-information
```

```example
starwars/character-information
```

## Full Profile Identifier

FullProfileIdentifier : ProfileIdentifier @ SemanticVersion

SemanticVersion : MajorVersion MinorVersion PatchVersion

MajorVersion : IntegerValue

MinorVersion : `.`IntegerValue

PatchVersion : `.`IntegerValue

Fully disambiguated identifier of a profile including its exact version.

```example
character-information@2.0.0
```

```example
starwars/character-information@1.1.0
```

## Map Profile Identifier

MapProfileIdentifier : ProfileIdentifier @ MajorVersion MinorVersion

Profile identifier used in maps does not include the patch number.

```example
starwars/character-information@1.1
```

## Provider Identifier

ProviderIdentifier : DocumentNameIdentifier

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
