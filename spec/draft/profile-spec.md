Comlink Profile
-----------------

*Current Working Draft*

**Introduction**

/Typed semantic profile/

/Use-case description language/

Comlink Profile is a simple format for describing application use-cases. It enables you to describe the business behavior of an application without the need to go into detail of implementation.

The profile language was designed with distributed systems applications in mind but can be used for describing any use cases or even for modeling entire domains using the DDD approach.

Unlike other formats (E.g. Gherkin) Profile does not support the description of actors, roles, or pre-requisites.  

Contrary to pure semantic profiles (e.g. ALPS) Superface Profile allows adding a type overlay for defined models to allow for the creation of rich developer experiences.

By convention, one profile file should comprise of one use case (E.g. “Get weather” or “Make payment”).

When submitted to a profile store, the profile must be assigned a globally unique identifier in the form URL (preferably de-reference-able).

# Profile Document

ProfileDocument : Description? ProfileName ProfileVersion Usecase+ NamedModel* NamedField*

ProfileName : `name` = `"` ProfileIdentifier `"`

ProfileVersion : `version` = `"` SemanticVersion `"`

```example
name = "meteo/get-weather"
version = "1.0.0"

usecase GetWeather {
  ...
}
```

```example
name = "meteo/get-weather"
version = "1.0.0"

usecase GetWeather {
  ...
}

model WeatherInformation {
  ...
}
```

```example
name = "meteo/get-weather"
version = "1.0.0"

usecase GetWeather {
  ...
}

model WeatherInformation {
  ...
}

field location Place
```

# Description

Description : 
- `"` String `"`
- `"""` String `"""`

Any definition in the profile document can have a preceding human-readable description. Any string literal or block string literal preceding a definition is treated as a description.

```example
"Use-case description"
usecase GetWeather {
  ...
}
```

```example
"""
Retrieve Weather Information

Use-case description
"""
usecase GetWeather {
  ...
}
```

# Use-case

Usecase : Description? `usecase` UsecaseName Safety? { Input? Result? AsyncResult? Error* Example* }

UsecaseName: Name

Safety : one of safe unsafe idempotent

Input : input ObjectModel

Result : result ModelDefinition

AsyncResult : async result ModelDefinition

Error : error ModelDefinition

```example
usecase GetWeather {
  input {
    location
    units
  }

  result {
    airTemperature
    atmosphericPressure
  }
}
```

```example
"""
Send Message

Send single conversation message
"""
usecase SendMessage unsafe {
  input {
    "To
      recepient of the message"
    to

    "From
      sender of the message"    
    from
    
    channel

    "Text 
      the text of the message"
    text
  }

  result {
    messageId
  }

  async result {
    messageId
    deliveryStatus
  }

  error {
    problem
    detail
    instance
  }
}
```

# Models 

## Named Model 

NamedModel : Description? `model` ModelName ModelDefinition

ModelName : Identifier

## Model Definition

ModelDefinition : 

- ObjectModel
- ListModel
- EnumModel
- UnionModel
- AliasModel
- ScalarModel

ModelSpecification: 

- ModelDefinition
- ModelReference

ModelReference : ModelName

### Object Model

ObjectModel : { FieldDefinition* }

```example
model WeatherInformation {
  airTemperature
  atmosphericPressure
}
```

The field definitions of an object model type MUST be separated by a newline or comma `,` :

```example
// Newline-separated
{
  airTemperature
  atmosphericPressure
}

// Comma-separated
{ airTemperature, atmosphericPressure }
```

### List Model

ListModel : `[` ModelSpecification `]`

```example
model WeatherHistory [ WeatherInformation ]
```

### Enum Model

EnumModel : enum { EnumElement }

EnumElement : EnumElementName EnumElementValue? 

EnumElementName : Identifier

EnumElementValue : = ScalarValue

```example
model Channel enum {
  sms
  whatsapp
  viber
}
```

```example
model Unit enum {
  "Degrees of Celsius"
  C = 'celsius'

  "Degrees of Fahrenheit"
  F = 'fahrenheit'
}
```

```example
model Values enum {
  byte = 8
  kiloByte = 1024
  fourKiloBytes = 4096
}
```

```example
// Newline-separated
enum {
  sms
  whatsapp
  viber
}

// Comma-separated
enum { sms, whatsapp, viber }
```

### Union Model

UnionModel : ModelReference UnionModelReferenceList+

UnionModelReferenceList : | ModelReference

```example
model WeatherData WeatherHistory | WeatherInformation
```

### Alias Model

AliasModel : ModelReference

```example
model MyWeather WeatherInformation
```

### Scalar Model

ScalarModel : ScalarType?

```example
model Place
```

Scalar models can have a type overlay using one of the built-in primitive types:

```example
model Place string
```

# Fields

## Named Field

NamedField : Description? `field` FieldDefinition

## Field Definition

FieldDefinition : Description? FieldName RequiredField? FieldSpecification? 

FieldName : Identifier

RequiredField : `!`

FieldSpecification : ModelSpecification NonNullField?

NonNullField : `!`

### Required fields

By default all fields are optional. To declare field that is required use {RequiredField} after {FieldName}

```example
model User {
  name! string      // the field "name" is required (but can be null)
  email string      // the field "email" is optional
}
```

### Non-null field value

By default all fields are nullable. To declare field that can be null use {NonNullField} after {FieldSpecification}

```example
model User {
  name string!      // value of name can not be null
  email string      // value of email can be null
}
```

# Example

Example : example Identifier? { ExampleInput ExampleOutput }

ExampleInput : input ComlinkLiteral

ExampleOutput : 
- ExampleResult
- ExampleError

ExampleResult : result ComlinkLiteral

ExampleError : error ComlinkLiteral

# Literal

## Comlink Literal

ComlinkLiteral :
- PrimitiveLiteral
- ObjectLiteral
- ArrayLiteral

## Primitive Literal

PrimitiveLiteral : StringValue | NumberLiteral | BooleanLiteral

NumberLiteral: NumberSign? NumberLiteralDigits

NumberSign : `-` | `+`

NumberLiteralDigits : NumberLiteralInteger | NumberLiteralFloat

NumberLiteralInteger : NumberLiteralIntegerBaseTen | NumberLiteralIntegerBaseTwo | NumberLiteralIntegerBaseEight | NumberLiteralIntegerBaseSixteen

NumberLiteralIntegerBaseTen : DigitBaseTen+

NumberLiteralIntegerBaseTwo : 0b DigitBaseTwo+

NumberLiteralIntegerBaseEight : 0o DigitBaseEight+

NumberLiteralIntegerBaseSixteen : 0x DigitBaseSixteen+

DigitBaseTen : /[0-9]/

DigitBaseTwo : /[0-1]/

DigitBaseEight : /[0-7]/

DigitBaseSixteen : /[0-9a-fA-F]/

NumberLiteralFloat : DigitBaseTen+ . DigitBaseTen+

BooleanLiteral : `true` | `false`

## Object Literal

ObjectLiteral : { KeyValueAssignment* }

KeyValueAssignment : LHS = ComlinkLiteral

LHS : VariableName VariableKeyPath[ObjectVariable]*

VariableName : 
- Identifier
- StringValue

VariableKeyPath[ObjectVariable] : `.`VariableName

## Array Literal

ArrayLiteral : [ ArrayItems? ]

ArrayItems : ComlinkLiteral ArrayItemContinued*

ArrayItemContinued : , ComlinkLiteral

# Types

## Primitive types

ScalarType : one of boolean string number

# Language

[SLANG source text](common/source-text.md)

[SLANG common definitions](common/definitions.md)
