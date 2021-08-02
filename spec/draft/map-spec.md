Superface Map
--------------

*Current Working Draft*

**Introduction**

Comlink Map is a format for describing one concrete implementation of a Comlink Profile. It essentially maps the application (business) semantics into provider's interface implementation.

# Map Document

MapDocument : Profile Provider Variant? Map+ Operation*

Profile : `profile` = `"` MapProfileIdentifier `"`

Provider : `provider` = `"` ProviderIdentifier `"`

Variant : DocumentNameIdentifier

Defines a document that maps a profile into a particular provider's API. At minimum, the map document consists of the profile and provider identifiers and a profile use-case map. 

Optionally, map document may specify a variant. {Variant} allows for mutliple maps for the same {MapProfileIdentifier} and {ProviderIdentifier}.


```example
profile = "conversation/send-message"
provider = "some-telco-api"

map SendMessage {
  ...
}

map RetrieveMessageStatus {
  ...
}
```

```example
profile = "conversation/send-message"
provider = "some-telco-api"
variant = "my-bugfix"

map SendMessage {
  ...
}

map RetrieveMessageStatus {
  ...
}
```

# Usecase Map

Map : map UsecaseName { MapSlot* }

UsecaseName : Identifier

MapSlot :

- SetVariables
- OperationCall
- NetworkCall
- MapResult
- MapError

**Context Variables**

{Map} context variables :

- {input} - User input as stated in the profile

```example
map RetrieveMessageStatus {  
  http GET "/chat-api/v2/messages/{input.messageId}/history" {
    response 200 "application/json" {
      map result {
        deliveryStatus = body.history[0].state
      }
    }
  } 
}
```

## Map Result

MapResult : `return`? `map result` Condition? SetMapResultVariables?

SetMapResultVariables: VariableStatements

```example
map GetWeather {
  map result {
    airTemperature = 42  # Sets the value returned to user
  }
}
```

## Map Error

MapError : `return`? `map error` Condition? SetMapErrorVariables?

SetMapErrorVariables: VariableStatements

```example
map GetWeather {
  map error {
    title = "Location not found"
  }
}
```

# Operation

Operation : operation OperationName { OperationSlot* }

OperationName : Identifier

OperationSlot :

- SetVariables
- OperationCall
- NetworkCall
- OperationReturn
- OperationFail

**Context Variables**

{Operation} context variables :

- {args} - arguments as passed in the parent's {OperationCall}

```example
operation CountArray {
  return {
    answer = "This is the count " + args.array.length
  }
}
```

## Operation Return

OperationReturn : `return` Condition? SetOperationReturnVariables?

SetOperationReturnVariables: VariableStatements

```example
operation Foo {
  return if (args.condition) {
    message = "I have a condition!"
  }

  return {
    message = "Hello World!"
  }
}
```

## Operation Fail

OperationFail : `fail` Condition? SetOperationFailVariables?

SetOperationFailVariables: VariableStatements

```example
operation Foo {
  fail if (args.condition) {
    errorMessage = "I have failed!"
  }
}
```

# Set Variables

SetVariables : `set` Condition? VariableStatements

VariableStatements : { VariableStatement+ }

VariableStatement : LHS `=` RHS

LHS : VariableName VariableKeyPath[ObjectVariable]*

VariableName : 
- Identifier
- StringValue

VariableKeyPath[ObjectVariable] : `.`KeyName

KeyName[ObjectVariable] : Identifier

RHS :

- ScriptExpression
- OperationCallShorthand

```example
set {
  variable = 42
}
```

```example
set if (true) {
  variable = 42
}
```

```example
set {
  variable.key = 42
}
```

```example
set {
  variable = call ConvertToCelsius(tempF = 100)
}
```

# Operation Call

OperationCall: `call` Iteration? OperationName OperationArguments? Condition? OperationCallSlot?

OperationArguments : ( Argument* )

Argument : Identifier `=` ScriptExpression

OperationCallSlot: { SetVariables* SetOutcome* }

**Condition and iteration**

When both {Condition} and {Iteration} are specified, the condition is evaluated for every element of the iteration.

**Context Variables**

{OperationCallSlot} context variables:

- `outcome.data` -  data as returned by the callee
- `outcome.error` - error as returned by the callee

```example
operation Bar {
  set {
    variable = 42
  }

  call FooWithArgs(text = `My string ${variable}` some = variable + 2 ) {
    return if (!outcome.error) {
      finalAnswer = "The final answer is " + outcome.data.answer
    }

    fail if (outcome.error) {
      finalAnswer = "There was an error " + outcome.error.message
    }
  }
}
```

```example
map RetrieveCustomers {
  // Local variables
  set {
    filterId = null
  }


  // Step 1
  call FindFilter(filterName = "my-superface-map-filter") if(input.since) {
    // conditional block for setting the variables
    set if (!outcome.error) {
      filterId = outcome.data.filterId
    }
  }

  // Step 2
  call CreateFilter(filterId = filterId) if(input.since && !filterId) {
    set if (!outcome.error) {
      filterId = outcome.data.filterId
    }
  }

  // Step 3
  call RetrieveOrganizations(filterId = filterId) {
    map result if (!outcome.error && outcome.data) {
      customers = outcome.data.customers
    }
  }

  // Step 4
  call Cleanup() if(filterId) {
    // ...
  }
}
```

```example
operation Baz {
  array = [1, 2, 3, 4]
  count = 0
  data = []

  call foreach(x of array) Foo(argument = x) if (x % 2) {
    count = count + 1
    data = data.concat(outcome.data)
  }
}
```

Note there is a convenient way to call operations in {VariableStament}. Using the {OperationCallShorthand}, the example above can be written as: 

```example
operation Baz {
  array = [1, 2, 3, 4]
  data = call foreach(x of array) Foo(argument = x) if (x % 2)
  count = data.length
}
```

## Operation Call Shorthand

OperationCallShorthand: `call` Iteration? OperationName OperationArguments? Condition?

Used as {RHS} instead of {ScriptExpression} to invoke an {Operation} in-place. In the case of success the operation outcome's data is unbundled and returned by the call. See {OperationCall} context variable `outcome`.

```example
set {
  someVariable = call Foo
}
```

**Iteration and operation call shorthand**

When an iteration is specified ther result of the {OperationCallShorthand} is always an array.


```example
operationOutcome = call SomeOperation()

users = call foreach(user of operationOutcome.users) Foo(user = user) if (operationOutcome)

// Intepretation: 
// `Foo` is called for every `user` of `operationOutcome.users` if the `operationOutcome` is truthy

superusers = call foreach(user of operationOutcome.users) Bar(user = user) if (user.super)

// Intepretation: 
// `Bar` is called for an `user` of `operationOutcome.users` if the `user.super` is truthy
```


# Outcome

SetOutcome[Map, Operation] :

- [if Map] SetMapOutcome
- [if Operation] SetOperationOutcome

Evaluation of a use-case map or operation outcome. The outcome definition depends on its context. When specified in the {Map} context the outcome is defined as {SetMapOutcome}. When specified in the {Operation} context the outcome is defined as {SetOperationOutcome}.

## Map Outcome

SetMapOutcome :

- MapResult
- MapError

Outcome in the {Map} context.

## Operation Outcome

SetOperationOutcome :

- OperationReturn
- OperationFail

Outcome in the {Operation} context.

# Network Operation

NetworkCall :

- HTTPCall
- GraphQLCall

# HTTP Call

HTTPCall : `http` HTTPMethod ServiceIdentifier? URLTemplate { HTTPTransaction }

HTTPMethod : one of GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH 

URLTemplate : `"` URLPath+ `"` 

URLPath : `/` URLPathSegment

URLPathSegment : 
- URLPathLiteral 
- URLPathVariable

URLPathLiteral : StringCharacter+

URLPathVariable : { VariableName }

```example
map SendMessage {
  http POST "/chat-api/v2/messages" {
    request "application/json" {
      body {
        to = input.to
        channels = ['sms']
        sms.from = input.from
        sms.contentType = 'text'
        sms.text = input.text
      }
    }

    response 200 "application/json" {
      map result {
        messageId = body.messageId
      }
    }
  }
}
```

Example of HTTP call to a service other than the `defaultService`.

```example
http GET service2 "/users" {
  ...
}
```

## HTTP Transaction

HTTPTransaction : HTTPSecurity? HTTPRequest? HTTPResponse*

## HTTP Security 

HTTPSecurity : `security` SecuritySchemeIdentifier

```example
GET "/users" {
  security "api_key_scheme_id"

  response {
    ...
  }
}
```

If no other {HTTPSecurity} is provided, the default is `none`. Explicitly signify public endpoints as `none` as so. 

```example
GET "/public-endpoint" {
  security none
  
  response {
    ...
  }
}
```

## HTTP Request

HTTPRequest : `request` ContentType? ContentLanguage? { HTTPRequestSlot* }

HTTPRequestSlot :

- URLQuery
- HTTPHeaders
- HTTPBody

URLQuery : `query` VariableStatements

HTTPHeaders : `headers` VariableStatements

HTTPBody : `body` HTTPBodyValueDefinition

HTTPBodyValueDefinition:

- HTTPRequestBodyAssignment
- VariableStatements

HTTPRequestBodyAssignment : `=` RHS

```example
http GET "/greeting" {
  request {
    query {
      myName = "John"
    }
  }
}
```

```example
http POST "/users" {
  request "application/json" {
    query {
      parameter = "Hello World!"
    }

    headers {
      "my-header" = 42
    }

    body {
      key = 1
    }
  }
}
```


```example
http POST "/users" {
  request "application/json" {
    body = [1, 2, 3]
  }
}
```

## HTTP Response

HTTPRespose : `response` StatusCode? ContentType? ContentLanguage? { HTTPResponseSlot* }

HTTPStatusCode: IntegerValue

ContentType: StringValue

ContentLanguage: StringValue

HTTPResponseSlot :

- SetVariables
- SetOutcome

**Context Variables**

{HTTPResponseSlot} context variables :

- {statusCode} - HTTP response status code parsed as number
- {headers} - HTTP response headers in the form of object
- {body} - HTTP response body parsed as JSON


```example
http GET "/" {
  response 200 "application/json" {
    map result {
      outputKey = body.someKey
    }
  }
}
```

```example
http POST "/users" {
  response 201 "application/json" {
    return {
      id = body.userId
    }
  }
}
```

Handling HTTP errors:

```example
http POST "/users" {
  response 201 "application/json" {
    ...
  }
  
  response 400 "application/json" {
    map error {
      title = "Wrong attributes"
      details = body.message
    }
  }
}
```

Handling business errors:

```example
http POST "/users" {
  response 201 "application/json" {
    map result if(body.ok) {
      ...
    }

    map error if(!body.ok) {
      ...
    }
  }
}
```

When {ContentType} is not relevant but {ContentLanguage} is needed, use the `*` wildchar in place of the {ContentType} as follows:

```example
http GET "/" {
  response  "*" "en-US" {
    map result {
      rawOutput = body
    }
  }
}
```

# Conditions

Condition : `if` ( JessieExpression )

Conditional statement evalutess its {JessieExpression} for truthiness.

```example
if ( true )
```

```example
if ( 1 + 1 )
```

```example
if ( variable % 2 )
```

```example
if ( variable.length == 42 )
```

# Iterations

Iteration : `foreach` ( VariableName `of` JessieExpression )

When the given {JessieExpression} evaluates to an array (or any other ECMA Script iterable), this statement iterates over its elements assigning the respective element value to its context {VariableName} variable.

```example
foreach (x of [1, 2, 3])
```

```example
foreach (element of variable.nestedArray)
```

# Script

This is a subset of Javascript programming language designed to be familiar to a great number of programmers while reducing the possible attack surface of the runtime environment.

This specification is based on and references [ECMA 262](https://262.ecma-international.org/11.0) and heavily inspired by [Jessie](https://github.com/endojs/Jessie/).

## Operators

ScriptUnaryOperator: one of + - ! ~

ScriptBinaryOperator: one of + - * ** `/` % && || << >> >>> & | ^ < > <= >= === !==

ScriptAssignmentOperator: one of = += -= *= `/=`

Note: This omits the following operators which are defined in Javascript grammar: `++ -- == != %= <<= >>= >>>= &= |= ^=`

## Literals

ScriptLiteral:
- ScriptPrimitiveLiteral
- ScriptArrayLiteral
- ScriptObjectLiteral

### Primitive

ScriptPrimitiveLiteral: "One of the allowed Javascript literal productions"

The allowed Javascript literal productions are:
- `undefined`
- [DecimalLiteral](https://262.ecma-international.org/11.0/#prod-DecimalLiteral)
- [NonDecimalIntegerLiteral](https://262.ecma-international.org/11.0/#prod-NonDecimalIntegerLiteral)
- [StringLiteral](https://262.ecma-international.org/11.0/#prod-StringLiteral)
- [BooleanLiteral](https://262.ecma-international.org/11.0/#prod-BooleanLiteral)
- [NullLiteral](https://262.ecma-international.org/11.0/#prod-NullLiteral)
- [Template](https://262.ecma-international.org/11.0/#prod-Template)

```example
1.234e-4
```

```example
"hello world"
```

```example
`Foo: ${foo}, bar: ${bar}`
```

Note: This corresponds to [NumericLiteral](https://262.ecma-international.org/11.0/#prod-NumericLiteral) without [DecimalBigIntegerLiteral](https://262.ecma-international.org/11.0/#prod-DecimalBigIntegerLiteral).

### Array

ScriptArrayLiteral: [ ScriptArrayLiteralElement[comma]* ]

ScriptArrayLiteralElement:
- ScriptExpression
- ... ScriptExpression

```example
[...[1, 2], 3, 4]
```

Note: This corresponds to [ArrayLiteral](https://262.ecma-international.org/11.0/#prod-ArrayLiteral) without `yield`, `await` and [Elision](https://262.ecma-international.org/11.0/#prod-Elision).

### Object

ScriptObjectLiteral: { ScriptObjectLiteralAssignment[comma]* }

ScriptObjectLiteralAssignment:
- ScriptIdentifier: ScriptExpression
- ScriptIdentifier
- ... ScriptExpression

```example
{ ...a, b: 1, c: 2 + 3 }
```

Note: This corresponds to [ObjectLiteral](https://262.ecma-international.org/11.0/#prod-ObjectLiteral) without `yield`, `await`, [CoverInitializedName](https://262.ecma-international.org/11.0/#prod-CoverInitializedName), [ComputedPropertyName](https://262.ecma-international.org/11.0/#prod-ComputedPropertyName) and [MethodDefinition](https://262.ecma-international.org/11.0/#prod-MethodDefinition).

## Identifiers

ScriptIdentifier: "Javascript identifier production"

[Javascript identifier production](https://262.ecma-international.org/11.0/#prod-Identifier)

ScriptReservedWord: "Javascript reserved word production"

[Javascript reserved word production](https://262.ecma-international.org/11.0/#prod-ReservedWord)

Note: Reserved words that are not keywords cannot be used because they would conflict with the Javascript grammar.

ScriptKeyword: one of break case const continue default do else false
for if null return switch true while

## Expressions

Expressions are the bread and butter of the script. Expressions appear on the right-hand side of {VariableStatement}, in {Condition}s and in operation call {Argument} list.

Since the only way to obtain a lexical context in which statements can be declared is to create an {ScriptArrowFunction} it is often more convenient to use functional patterns to transform data:

```example
Object.entries(foo).filter(
  ([_key, value]) => value > 0
).map(
  ([key, _value]) => key
)
```

ScriptExpression:
- ScriptLiteral
- ScriptIdentifier
- ScriptUnaryExpression
- ScriptBinaryExpression
- ScriptAssignmentExpression
- ScriptTernaryExpression
- ScriptCallExpression
- ScriptArrowFunction
- ( ScriptExpression )

```example
1 + 2**input.exponent
```

```example
{ ...a, b: 1, c: 2 + 3, d: [...[1, 2], 3, 4] }
```

```example
(() => {
  const result = "only do this in very complex cases"
  return result
})()
```

Note: This corresponds to [PrimaryExpression](https://262.ecma-international.org/11.0/#prod-PrimaryExpression) without `this`, [FunctionExpression](https://262.ecma-international.org/11.0/#prod-FunctionExpression), [ClassExpression](https://262.ecma-international.org/11.0/#prod-ClassExpression), [GeneratorExpression](https://262.ecma-international.org/11.0/#prod-GeneratorExpression), [AsyncFunctionExpression](https://262.ecma-international.org/11.0/#prod-AsyncFunctionExpression), [AsyncGeneratorExpression](https://262.ecma-international.org/11.0/#prod-AsyncGeneratorExpression) and [RegularExpressionLiteral](https://262.ecma-international.org/11.0/#prod-RegularExpressionLiteral).

### Unary

ScriptUnaryExpression: ScriptUnaryOperator ScriptExpression

```example
-7
```

### Binary

ScriptBinaryExpression: ScriptExpression ScriptBinaryOperator ScriptExpression

```example
"foo" + "bar"
```

ScriptAssignmentExpression: ScriptExpression ScriptAssignmentOperator ScriptExpression

```example
foo.bar += 7 * 8
```

### Ternary

ScriptTernaryExpression: ScriptExpression ? ScriptExpression : ScriptExpression

```example
foo === 1 ? "hello" : "goodbye"
```

### Call

ScriptCallExpression: ScriptExpression ( ScriptExpression[comma]* )

```example
foo.bar(1, 2 + 3, ["hello", "world"])
```

## Binding patterns

Binding patterns are used when destructuring values in variable declarations and function parameter declarations (i.e. in {ScriptArrowFunction}).

ScriptBindingPattern: "Javascript binding pattern production"

Javascript binding pattern production: [BindingPattern](https://262.ecma-international.org/11.0/#prod-BindingPattern) without `yield`, `await`, [Elision](https://262.ecma-international.org/11.0/#prod-Elision) and [ComputedPropertyName](https://262.ecma-international.org/11.0/#prod-ComputedPropertyName).

```example
[a, b = 2, ...c]
```

```example
{ a, b = 2, c: x = 3, ...d }
```

## Arrow function

Arrow functions are the only way to declare callable items in the script. They can be passed to built-in methods like `Array.map` or in the most complex cases uses as immediately invoked function expressions (e.g. `(() => 1)()`).

ScriptArrowFunction: "Javascript arrow function production"

```example
([a, b, c = 1]) => { return a + b ** c; }
```

Note: Javascript arrow function production: [ArrowFunction](https://262.ecma-international.org/11.0/#prod-ArrowFunction) without `yield`, `await` and where [FunctionBody](https://262.ecma-international.org/11.0/#prod-FunctionBody) is replaced by {ScriptStatement*}.


## Statements

Statements are usually not very relevant in the script, as expressions should be preferred instead.

ScriptStatement: "One of the allowed Javascript statement productions"

The allowed Javascript statement productions are with the following caveats recursively:
- Each production without `yield`, `await` and [Declaration](https://262.ecma-international.org/11.0/#prod-Declaration)
- [IterationStatement](https://262.ecma-international.org/11.0/#prod-IterationStatement) without `for/in` and without async variants
- [AssignmentExpression](https://262.ecma-international.org/11.0/#prod-AssignmentExpression) production replaced by {ScriptExpression}
- [Statement](https://262.ecma-international.org/11.0/#prod-Statement) production replaced by {ScriptStatement}

The allowed Javascript statement productions are:
- [LexicalDeclaration](https://262.ecma-international.org/11.0/#prod-LexicalDeclaration) (`let`, `const`)
- [BlockStatement](https://262.ecma-international.org/11.0/#prod-BlockStatement)
- [ExpressionStatement](https://262.ecma-international.org/11.0/#prod-ExpressionStatement)
- [IfStatement](https://262.ecma-international.org/11.0/#prod-IfStatement)
- [BreakableStatement](https://262.ecma-international.org/11.0/#prod-BreakableStatement) (`for`, `for/of`, `while`, `do/while`, `switch`)
- [ContinueStatement](https://262.ecma-international.org/11.0/#prod-ContinueStatement), [BreakStatement](https://262.ecma-international.org/11.0/#prod-BreakStatement), [ReturnStatement](https://262.ecma-international.org/11.0/#prod-ReturnStatement) where appropriate
- [LabelledStatement](https://262.ecma-international.org/11.0/#prod-LabelledStatement)

```example
return 1;
```

```example
{
  let x = 1;
  for (const y of [1, 2, 3]) {
    x += y;
  }

  if (x == 7) {
    return null;
  }
}
```

# Language

[SLANG source text](common/source-text.md)

[SLANG common definitions](common/definitions.md)

# A. Appendix: Keywords

TODO:
