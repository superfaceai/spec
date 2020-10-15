Superface Map
=============

Superface map is a format describing one concrete implementation of a Superface profile. It essentially maps the application (business) semantics into concrete interface implementation.

# Map Document

MapDocument :

- Profile
- Provider
- Map+
- Operation*

Profile : `profile` = ProfileId

ProfileId : URLValue

Provider : `provider` = ProviderId

ProviderId : URLValue

```example
profile = "http://superface.ai/profile/conversation/SendMessage"
provider = "http://superface.ai/directory/MyTelcoCompany"

map SendMessage {
  ...
}

map RetrieveMessageStatus {
  ...
}
```

# Usecase Map

Map : UsecaseName { MapSlot* }

UsecaseName : Name

MapSlot :

- SetVariables
- OperationCall
- NetworkCall
- MapResult
- MapError

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

Operation : OperationName { OperationSlot* }

OperationName : Name

OperationSlot :

- SetVariables
- OperationCall
- NetworkCall
- OperationReturn
- OperationFail

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
- Name
- StringValue

VariableKeyPath[ObjectVariable] : `.`KeyName

KeyName[ObjectVariable] : Name

RHS :

- JessieExpression
- OperationCall

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

OperationCall: `call` OperationName OperationArguments? Condition? OperationCallSlot?

OperationArguments : ( Argument* )

Argument : Name `=` JessieExpression

OperationCallSlot: { SetVariables* SetOutcome* }

{OperationCallSlot} context variables:

- {data} - data as returned by the callee
- {error} - error as returned by the callee

```example
operation Bar {
  set {
    variable = 42
  }

  call FooWithArgs(text = `My string ${variable}` some = variable + 2 ) {
    return if (!error) {
      finalAnswer = "The final answer is " + data.answer
    }

    fail if (error) {
      finalAnswer = "There was an error " + error.message
    }
  }
}
```

```example
map RetrieveCustomers {
  # Local variables
  set {
    filterId = null
  }


  # Step 1
  call FindFilter(filterName = "my-superface-map-filter") if(input.since) {
    # conditional block for setting the variables
    set if (!error) {
      filterId = data.filterId
    }
  }

  # Step 2
  call CreateFilter(filterId = filterId) if(input.since && !filterId) {
    set if (!error) {
      filterId = data.filterId
    }
  }

  # Step 3
  call RetrieveOrganizations(filterId = filterId) {
    map result if (!error && data) {
      customers = data.customers
    }
  }

  # Step 4
  call Cleanup() if(filterId) {
    # ...
  }
}
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

HTTPTransaction : HTTPRequest? HTTPResponse*

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
http GET / {
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
```


```example
http GET / {
  body = [1, 2, 3]
}
```

## HTTP Response

HTTPRespose : `response` StatusCode? ContentType? ContentLanguage? { HTTPResponseSlot* }

HTTPStatusCode: Number

ContentType: StringValue

ContentLanguage: StringValue

HTTPResponseSlot :

- SetVariables
- SetOutcome

{HTTPResponseSlot} context variables :

- {statusCode} - HTTP response status code parsed as number
- {headers} - HTTP response headers in the form of object
- {body} - HTTP response body parsed as JSON


```example
http GET / {
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
http GET / {
  response  "*" "en-US" {
    map result {
      rawOutput = body
    }
  }
}
```

# Conditions

Condition : `if` ( JessieExpression )

# Jessie

TODO: Well define what is Jessie and what expression we support

JessieExpression: JessieScript

# Language

## Name

Name :: /[_A-Za-z][_0-9A-Za-z]*/

## URL Value

URLValue :: `"` URL `"`

## String Value

StringValue :: `"` StringCharacter* `"`

StringCharacter ::
  - SourceCharacter but not `"` or \ or LineTerminator
  - \ EscapedCharacter

EscapedCharacter :: one of `"` \ `/` n r t

## Number

Number :: /[0-9]+/

## Comments

Comment :: `#` CommentChar*

CommentChar :: SourceCharacter but not LineTerminator

## Line Terminators

LineTerminator ::
  - "New Line (U+000A)"
  - "Carriage Return (U+000D)" [ lookahead ! "New Line (U+000A)" ]
  - "Carriage Return (U+000D)" "New Line (U+000A)"

## Source Text

SourceCharacter :: /[\u0009\u000A\u000D\u0020-\uFFFF]/


# A. Appendix: Keywords

TODO:
