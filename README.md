# @dashkite/runes-client

*Authenticated authorization for HTTP.*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

The `@dashkite/runes-client` module provides a client-side interface for managing capability-based authorization tokens (Runes). It manages the storage, retrieval, and evaluation of these capabilities within local storage environments.

## Features

- Securely store capability tokens (Runes) locally.
- Efficiently look up the best available capability for a given resource and method.
- Automatically discard expired tokens.
- Evaluate capabilities without requiring remote server roundtrips.

## Installation

Install the library using your package manager:

```bash
pnpm install @dashkite/runes-client
```

## Usage

A developer can use the client to store a token received from an authentication process, and later query it before making an HTTP request.

```coffeescript
import { store, lookup } from "@dashkite/runes-client"

# Store the token
store { rune, nonce }

# Query a capability for an upcoming request
result = lookup
  identity: "alice@acme.org"
  domain: "api.dashkite.io"
  resource: "workspace"
  method: "get"

if result?
  { credential, resources } = result
  # attach credential to the request...
```

## Other Resources

- [Usage Guides](docs/recipes.md)
- [API Reference](docs/reference.md)
- [Technical Notes](docs/technical-notes.md)
- [Testing Approach](docs/testing.md)
