Superface Map
--------------

*Current Working Draft*

**Introduction**

Superface map is a format describing one concrete implementation of a Superface profile. It essentially maps the application (business) semantics into provider's interface implementation.

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

- JessieExpression
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

Argument : Identifier `=` JessieExpression

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

Used as {RHS} instead of {JessieExpression} to invoke an {Operation} in-place. In the case of success the operation outcome's data is unbundled and returned by the call. See {OperationCall} context variable `outcome`.

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

HTTPCall : `http` HTTPMethod URLTemplate { HTTPTransaction }

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

## HTTP Transaction

HTTPTransaction : HTTPSecurity? HTTPRequest? HTTPResponse*

## HTTP Security 

HTTPSecurity : `security` HTTPSecurityScheme

HTTPSecurityScheme:

 - ApiKey
 - Basic
 - Bearer
 - Oauth
 - None

### Api Key Security Scheme

ApiKey: `apikey` ApiKeyPlacement { name = StringValue }

ApiKeyPlacement : one of `query` `header`

Authentication using an arbitrary API key. 

```example
GET "/users" {
  security apikey header {
    name = "my-api-key-header"
  }

  response {
    ...
  }
}
```

**Context Variables**

Using this scheme injects the following variables into the {HTTPRequest}'s context:

- `security.apikey.key` - API key

### Basic Security Scheme

Basic: `basic`

Basic authentication scheme as per [RFC7617](https://tools.ietf.org/html/rfc7617). 

**Context Variables**

Using this scheme injects the following variables into the {HTTPRequest}'s context:

- `security.basic.username` - Basic authentication user name
- `security.basic.password` - Basic authentication password

```example
GET "/users" {
  security basic
  
  response {
    ...
  }
}
```

### Bearer Security Scheme

Bearer: `bearer`

Bearer token authentication scheme as per [RFC6750](https://tools.ietf.org/html/rfc6750).

**Context Variables**

Using this scheme injects the following variables into the {HTTPRequest}'s context:

- `security.bearer.token` - Bearer token 

```example
GET "/users" {
  security bearer
  
  response {
    ...
  }
}
```

### Oauth Security Scheme

TODO: Add support for Oauth2

### No Security Scheme

None: `none`

Default security scheme if no other {HTTPSecurity} is provided. Explicitly signifies public endpoints. 

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
    error {
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

# Jessie

TODO: Define what is Jessie and what expression we support

JessieExpression: JessieScript


# Language

[SLANG source text](common/source-text.md)

[SLANG common definitions](common/definitions.md)

# A. Appendix: Keywords

TODO:
