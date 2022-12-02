import assert from "@dashkite/assert"
import { test } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import { issue, match } from "@dashkite/runes"

import { confidential } from "panda-confidential"

Confidential = confidential()

import { JSON36 } from "../src/helpers"
import { store, lookup } from "../src"
import "./local-storage"

import api from "./api"
import authorization from "./authorization"

globalThis.Sky =
  fetch: ( request ) ->
    # TODO possibly switch back to target using helper 
    #      to derive target from resource?
    { resource } = request
    switch resource.name
      when "description"
        content: api
      when "workspace"
        content: address: "acme"
      when "workspaces"
        content: [ { address: "acme" }, { address: "evilcorp" }]
      when "account"
        content: address: "alice"
      when "workspace-subscriptions"
        content: subscription: "active"
      else
        throw new Error "oops that's not a pretend resource!"

do ->

  secret = Confidential.convert
    from: "bytes"
    to: "base64"
    await Confidential.randomBytes 16

  { rune, nonce } = await issue { authorization, secret }

  print await test "@dashkite/runes-client",  [

    test "client", [

      test "store", ->
        assert.equal null, store { rune, nonce }

      test "lookup", ->
        result = lookup
          identity: "alice@acme.org"
          domain: "foo.dashkite.io"
          resource: "workspace"
          method: "get"
        assert result?
        assert.equal result.rune, rune
        assert.equal result.nonce, nonce

      test "lookup failure", ->
        result = lookup
          identity: "bob@acme.org"
          domain: "foo.dashkite.io"
          resource: "workspace"
          method: "get"
        assert !result?
    ]

        
  ]