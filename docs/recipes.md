# Runes Client Usage Guides

This document contains step-by-step guides for common tasks involving the `@dashkite/runes-client` module.

## How to store authentication tokens

A creator needs to safely persist authentication capabilities granted by a server so they can be reused for subsequent requests.

The `store` function decodes the capability token, extracts its grants, and categorizes them by identity and domain within local storage.

1. Obtain a token (rune) and its nonce from an authentication server.
2. Call the `store` function, passing an object with both the `rune` and `nonce`.
3. The client module automatically decodes the base64 token and persists the grants within `localStorage`.

```coffeescript
import { store } from "@dashkite/runes-client"

# implementation of token retrieval goes here
credential = retrieveTokenFromServer()
store credential
```

## How to evaluate capabilities before initiating requests

A creator needs to determine if the current environment possesses the necessary credentials to perform an action on a specific resource. This prevents unnecessary network traffic if the client is unauthorized.

The `has` and `lookup` functions search the local cache for a capability matching the required domain, resource, and HTTP method. They evaluate expirations dynamically, cleaning up stale tokens in the process.

1. Define the capability query including the creator identity, the target domain, the specific resource, and the requested method.
2. Pass the query to the `has` function for a simple boolean check, or to the `lookup` function to retrieve the actual credential.
3. If a match is found using `lookup`, extract the `credential` object containing the `rune` and `nonce` to include in your HTTP headers.

```coffeescript
import { has, lookup } from "@dashkite/runes-client"

query =
  identity: "alice@acme.org"
  domain: "api.dashkite.io"
  resource: "workspace"
  method: "get"

# boolean check for conditional UI rendering
canRead = has query

if canRead
  # extract credentials for the actual request
  result = lookup query
  # implementation of HTTP request using result.credential goes here
  makeRequest result.credential
```

## How to verify specific capability grants directly

A creator needs to manually evaluate an isolated Rune string against a set of capability requirements without relying on the local storage cache.

The `hasGrant` function parses the provided Rune string and evaluates its embedded grants against the given query, returning a boolean indicating authorization status.

1. Obtain the raw Rune token string and define the capability requirement query.
2. Call the `hasGrant` function, providing the Rune and the query object.
3. Use the resulting boolean value to authorize or deny the action.

```coffeescript
import { hasGrant } from "@dashkite/runes-client"

# implementation of specific token extraction goes here
tokenString = extractToken()

isValid = hasGrant tokenString,
  domain: "api.dashkite.io"
  resource: "workspace"
  method: "get"
```

## How to perform targeted cleanup of expired or bound credentials

A creator needs to explicitly revoke a capability or clean up cached grants to ensure the local environment remains secure and consistent with the server state.

The client module provides granular deletion through `remove` for specific tokens, and broad cleanup through `removeBound` for unconstrained grants.

1. To remove a specific token after an explicit logout or token revocation, call the `remove` function with the target identity, domain, rune, and nonce.
2. To periodically clean up unconstrained (bound) grants, call `removeBound` with the identity and domain.

```coffeescript
import { remove, removeBound } from "@dashkite/runes-client"

identity = "alice@acme.org"
domain = "api.dashkite.io"

# explicitly remove a specific revoked token
remove { identity, domain, rune: "...", nonce: "..." }

# clean up unconstrained grants
removeBound { identity, domain }
```
