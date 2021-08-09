Comlink Provider Definition
---------------------------

*Current Working Draft*

**Introduction**

A Provider Definition is a JSON description of provider and the provider's services. Comlink Maps make use of the Provider Definition by defining which service to call based on the Service ID and which security scheme to use based on the Security Scheme ID. A Provider Definition can be reused across many profiles and maps which is why it has its own separate definition.

# Provider Definition

This is the root of the Provider Definition file.

- `services` (array of Service)
- `securitySchemes` (array of Security Scheme)
- `defaultService` (string) - References the ID of an existing Service

```js example
{
  "services": [
    {
      "id": "main",
      "baseUrl": "https://main.example.com/"
    }
  ],
  "defaultService": "main",
  "securitySchemes": [
    {
      "id": "basicAuth",
      "type": "http",
      "scheme": "basic"
    }
  ]
}
```

# Service

A service is software that makes itself available over the internet.

- `id` (string) - Unique ID for service
- `baseUrl` - Base URL for the service

## Default Service

A provider can have several services associated with it. Comlink Maps allow for leaving out the service ID when specifying an HTTP call and defaulting to the `defaultService` as defined in the provider definition.

# Security Scheme

The Provider Definition includes security schemes that describe the ways a client must authenticate and authorize in order to use the provider API. These security schemes are referenced in maps as security requirements. The security schemes in a Provider Definition declare how security works for a provider, while the security requirements in the map describe which HTTP calls use those security schemes.

- OneOf
  - API Key Header
  - API Key Query Parameter
  - Basic Auth
  - Bearer Token

## Security Scheme Types

### API Key Header

For this security scheme, the client should add the API key into a specified HTTP header.

- `id` (string) - Unique ID for security scheme
- `type`: "apiKey" (string)
- `in`: "header" (string)
- `name` (string) - Name of HTTP header

```js example
{
  "id": "my-api-key-header",
  "type": "apiKey",
  "in": "header",
  "name": "API-Key"
}
```

In this example, the `name` refers to the HTTP header name.

### API Key Query Parameter

For this security scheme, the client should add the API key into a specified query parameter.

- `id` (string) - Unique ID for security scheme
- `type`: "apiKey" (string)
- `in`: "query" (string)
- `name` (string) - Name of query parameter

```js example
{
  "id": "my-api-key-query-param",
  "type": "apiKey",
  "in": "query",
  "name": "apiKey"
}
```

In this example, the `name` refers to the query parameter to use for this security scheme.

### Basic Auth

This security scheme refers to HTTP Basic Authentication as described in [RFC 7235](https://datatracker.ietf.org/doc/html/rfc7235).

- `id` (string) - Unique ID for security scheme
- `type`: "http" (string)
- `scheme`: "basic" (string)

```js example
{
  "id": "my-basic-auth",
  "type": "http",
  "scheme": "basic"
}
```

### Bearer Token

- `id` (string) - Unique ID for security scheme
- `type`: "http" (string)
- `scheme`: "bearer" (string)
- `bearerFormat` (string, optional) - A hint to the client to identify how the bearer token is formatted for documentation purposes only

```js example
{
  "id": "my-bearer-token",
  "type": "http",
  "scheme": "bearer",
  "bearerFormat": "JWT"
}
```

# JSON Schema

```yaml
$schema: http://json-schema.org/draft-07/schema
type: object
properties:
  name:
    type: string
    pattern: "^[a-z][_\\-0-9a-z]*$"
  services:
    type: array
    items:
      $ref: "#/definitions/Service"
    minItems: 1
  securitySchemes:
    type: array
    items:
      $ref: "#/definitions/SecurityScheme"
  defaultService:
    description: ServiceIdentifier must correspond to existing Service `id` from services.
    $ref: "#/definitions/ServiceIdentifier"
required:
- name
- services
- defaultService
definitions:
  Service:
    type: object
    properties:
      id:
        $ref: "#/definitions/ServiceIdentifier"
      baseUrl:
        type: string
        examples:
        - https://swapi.dev/api
    required:
    - id
    - baseUrl
  ServiceIdentifier:
    $ref: "#/definitions/Identifier"
  Identifier:
    type: string
    pattern: "[_A-Za-z][_0-9A-Za-z]*"
    examples:
    - swapidev
  SecurityScheme:
    oneOf:
    - $ref: "#/definitions/ApiKeyHeaderSecurity"
    - $ref: "#/definitions/ApiKeyQueryParamSecurity"
    - $ref: "#/definitions/BasicAuthSecurity"
    - $ref: "#/definitions/BearerTokenSecurity"
  SecurityIdentifier:
    $ref: "#/definitions/Identifier"
  ApiKeyHeaderSecurity:
    type: object
    properties:
      id:
        $ref: "#/definitions/Identifier"
      type:
        type: string
        enum:
        - apiKey
      in:
        type: string
        enum:
        - header
      name:
        type: string
        description: Name of header
        examples:
        - X-API-Key
    required:
    - id
    - type
    - in
    - name
  ApiKeyQueryParamSecurity:
    type: object
    properties:
      id:
        $ref: "#/definitions/SecurityIdentifier"
      type:
        type: string
        enum:
        - apiKey
      in:
        type: string
        enum:
        - query
      name:
        type: string
        description: Name of query parameter
    required:
    - id
    - type
    - in
    - name
  BasicAuthSecurity:
    type: object
    properties:
      id:
        $ref: "#/definitions/SecurityIdentifier"
      type:
        type: string
        enum:
        - http
      scheme:
        type: string
        enum:
        - basic
    required:
    - id
    - type
    - scheme
  BearerTokenSecurity:
    type: object
    properties:
      id:
        $ref: "#/definitions/SecurityIdentifier"
      type:
        type: string
        enum:
        - http
      scheme:
        type: string
        enum:
        - bearer
      bearerFormat:
        description: |
          A hint to the client to identify how the bearer token is formatted.
          Bearer tokens are usually generated by an authorization server, so this
          information is primarily for documentation purposes.
        type: string
        examples:
        - JWT
    required:
    - id
    - type
    - scheme
```