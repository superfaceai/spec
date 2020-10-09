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
    airTemperature = temp  # Sets the value returned to user
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

OperationReturn : `return` Condition? SetReturnVariables?

SetReturnVariables: VariableStatements

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

OperationFail : `fail` Condition? SetFailVariables?

SetFailVariables: VariableStatements

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

VariableName : Name

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

OperationCall: `call` OperationName OperationArguments? Condition? OperationCallEvaluation?

OperationArguments : ( Argument* )

Argument : Name `=` JessieExpression

OperationCallEvaluation: { SetVariables* SetOutcome* }

{OperationCallEvaluation} context variables:

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

Evaluation of a use-case map or operation outcome.

SetOutcome[Map, Operation] :

- [if Map] SetMapOutcome
- [if Operation] SetOperationOutcome

## Map Evaluation

SetMapOutcome :

- MapResult
- MapError

## Operation Evalutation

SetOperationOutcome :

- OperationReturn
- OperationFail

# Network Operation

NetworkCall :

- HTTPCall
- GraphQLCall

# HTTP Call

HTTPCall : http HTTPMethod URLTemplate { HTTPTransaction }

HTTPMethod : one of GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE PATCH 

URLTemplate : `"` URLPath+ `"` 

URLPath : `/` URLPathSegment

URLPathSegment : 
- URLPathLiteral 
- URLPathVariable

URLPathLiteral : String

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

- Query
- Headers
- Body

Query : `query` VariableStatements

Headers : `headers` VariableStatements

Body : `body` BodyValueDefinition

BodyValueDefinition:

- RequestBodyAssignment
- VariableStatements

RequestBodyAssignment : `=` RHS

## HTTP Response

HTTPRespose : `response` StatusCode? ContentType? ContentLanguage? { HTTPResponseSlot* }

StatusCode: Number

ContentType: StringValue

ContentLanguage: StringValue

HTTPResponseSlot :

- SetVariables
- SetOutcome

{HTTPResponseSlot} context variables :

- {statusCode} - HTTP response status code parsed as number
- {headers} - HTTP response headers in the form of object
- {body} - HTTP response body parsed as JSON

# Conditions

Condition : `if` ( JessieExpression )

# Jessie

TODO: Well define what is Jessie and what expression we support

JessieExpression: JessieScript

# General Types

## Name

TODO: Check for correct regex with @ELA

Name :: /[\_A-Za-z][_0-9a-za-z]/

## URL Value

URLValue :: `"` URL `"`

## String Value

StringValue :: `"` String `"`

## Number

Number :: /[0-9]/

## String

TODO: Check for correct regex with @ELA

String : /[\_A-Za-z][_0-9a-za-z]/

# A. Appendix: Keywords

TODO:

# B. Appendix: Spec Markdown

Written in [-->_Spec Markdown_<--](https://spec-md.com).
