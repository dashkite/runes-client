# Runes Client Testing Approach

This document outlines the testing strategy for the `@dashkite/runes-client` module.

## General Approach

The testing methodology relies on the `@dashkite/amen` testing framework to assert the correct behavior of capability storage and retrieval. The tests focus on evaluating the lifecycle of Rune tokens in an isolated environment.

To test the native Storage API interaction outside of a browser environment, the test suite injects a simulated `LocalStorage` interface into the global context. 

The test suite leverages the `@dashkite/runes` library to issue genuine cryptographically secure tokens. It then exercises the module interface to ensure the client correctly decodes, persists, retrieves, and evaluates the token grants. The tests verify successful lookups for authorized queries and successful rejections (returning undefined) for unauthorized queries.

## Running Tests

To execute the test suite, invoke the Genie task runner:

```bash
npx genie test
```
