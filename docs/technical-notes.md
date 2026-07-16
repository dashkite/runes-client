# Technical Notes

### Capability-based Security Model

The runes architecture relies on a capability-based security model. A capability-based security model embeds access rights directly into a token, eliminating the need for centralized permission lookups. The [W3C Web Authentication Working Group](https://www.w3.org/TR/webauthn-2/) and general computer science principles ([Wikipedia: Capability-based security](https://en.wikipedia.org/wiki/Capability-based_security)) outline how this model distributes trust. The token contains the authorization payload alongside a cryptographic Message Authentication Code (MAC) signature. The signature ensures the authorization payload cannot be tampered with by clients.

### DashKite Ecosystem Integration

The runes architecture is a variant of Cobalt and Web Grant technology. It integrates tightly with the `@dashkite/enchant` module, which evaluates complex rule expressions. The runes module delegates resource and method capability matching to the `@dashkite/enchant` action system, allowing developers to construct granular policy-based authorization schemes. The runes architecture utilizes the `@dashkite/joy` ecosystem to handle generic dispatch and iterate over asynchronous predicates, providing flexible evaluation sequences without synchronous blocking constraints.

### Capability Matching Strategy

The `runes-client` module implements a "best match" algorithm when searching for capabilities. When multiple tokens grant the required access, the client prefers tokens that require fewer resolvers. This optimizes the authorization process by utilizing the least restrictive token available, reducing the computational overhead of evaluating complex conditions during the actual HTTP request.

### Local Storage Schema

The module utilizes the browser's native [Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Storage) (`localStorage`), serializing the token state into a JSON representation. The storage schema organizes grants hierarchically by identity and domain. This structure ensures that capability queries remain scoped correctly and allows efficient retrieval without parsing the entire credential cache on every request.

### Base64 Serialization

Rune tokens are serialized as Base64 strings. The client utilizes the `panda-confidential` cryptographic suite to handle the conversion between UTF-8 strings and Base64 encoded bytes securely. This format ensures tokens can be safely transmitted in HTTP headers and stored safely in local browser storage.
