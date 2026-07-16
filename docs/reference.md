# Runes Client API Reference

This document provides a highly structured API reference for the `@dashkite/runes-client` module. The module exposes functions to manage authorization capabilities in local storage.

## Core Concepts

The module revolves around queries and credentials. A query specifies the capability requirement, including the creator `identity`, target `domain`, target `resource`, and the requested action `method`. A credential represents the capability token itself, containing the `rune` and its associated cryptographic `nonce`.

## store

$store: credential \to \emptyset$

The `store` function decodes a Rune token and persists its grants and resolvers into local storage. It associates them with the token's identity and domain. 

The `credential` argument represents an object containing the `rune` and `nonce` properties.

**Example**

```coffeescript
import { store } from "@dashkite/runes-client"

store { rune: "...", nonce: "..." }
```

## lookup

$lookup: query, options \to result$

The `lookup` function searches local storage for the best matching, non-expired capability token for a specific domain, resource, and method. It automatically removes any expired tokens it encounters.

The `query` object defines the required capability using `identity`, `domain`, `resource`, and `method`. The `options` object configures the search, such as determining if bound resolvers should be included via the `includeBound` boolean property. 

The function returns a `result` object containing the matched `credential` and required `resources`.

**Example**

```coffeescript
import { lookup } from "@dashkite/runes-client"

result = lookup
  identity: "alice@acme.org"
  domain: "api.dashkite.io"
  resource: "workspace"
  method: "get"

if result?
  console.log result.credential.rune
```

## has

$has: query \to boolean$

The `has` function provides a boolean check to determine if a valid capability exists for the given query without returning the credential itself.

The `query` argument matches the identical structure used in the `lookup` function.

**Example**

```coffeescript
import { has } from "@dashkite/runes-client"

canAccess = has
  identity: "alice@acme.org"
  domain: "api.dashkite.io"
  resource: "workspace"
  method: "get"
```

## hasGrant

$hasGrant: rune, query \to boolean$

The `hasGrant` function evaluates a specific raw Rune token string against a query to verify if it grants the required capabilities.

The `rune` argument expects a base64 encoded string representing the capability token. The `query` argument expects an object specifying the target `domain`, target `resource`, and requested `method`.

**Example**

```coffeescript
import { hasGrant } from "@dashkite/runes-client"

isValid = hasGrant myRuneToken,
  domain: "api.dashkite.io"
  resource: "workspace"
  method: "get"
```

## remove

$remove: details \to \emptyset$

The `remove` function securely deletes a specific Rune and its associated capabilities from local storage.

The `details` object specifies the target to remove using the `identity`, `domain`, `rune`, and `nonce` properties.

**Example**

```coffeescript
import { remove } from "@dashkite/runes-client"

remove
  identity: "alice@acme.org"
  domain: "api.dashkite.io"
  rune: "..."
  nonce: "..."
```

## removeBound

$removeBound: details \to \emptyset$

The `removeBound` function cleans up local storage by removing all capability grants that require zero resolvers for the specified identity and domain.

The `details` object defines the scope using the `identity` and `domain` properties.

**Example**

```coffeescript
import { removeBound } from "@dashkite/runes-client"

removeBound
  identity: "alice@acme.org"
  domain: "api.dashkite.io"
```
