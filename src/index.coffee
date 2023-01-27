import { JSON64 } from "./helpers"
import * as Val from "@dashkite/joy/value"

resourcesFind = ( resolver, resources ) -> 
  if resolver.action?
    if resolver.action.name == "request"
      { domain, method, resource } = resolver.action.value
      resources.push {
        domain
        method
        name: resource.name
      }
    else
      if resolver.action.value?
        resourcesFind resolver.action.value, resources

getResolverResources = ( resolver ) ->
  resources = []
  resourcesFind resolver, resources
  resources

checkExpiration = ( expires ) ->
  ( new Date expires ).getTime() >= ( Date.now() + 1000 )

getCandidateRunes = ( resource, method, grants ) ->
  candidates = []
  for grant in grants
    if grant.exclude?
      if !( resource in grant.exclude ) && grant.methods[ method ]?
        candidates.push grant.methods[ method ]
    else if grant.include? && grant.methods[ method ]?
      if ( resource in grant.include )
        candidates.push grant.methods[ method ]
  candidates

removeRune = ({ rune, nonce }, grants ) ->
  grants.filter ( grant ) ->
    for key, value of grant.methods
      if value.rune == rune && value.nonce == nonce
        return false
    return true

bestMatch = ( runes, includeBound ) ->
  if runes?
    expired = []
    best = {}
    for tuple in runes
      { rune, nonce, expires, numResolvers, grantResolvers } = tuple
      if checkExpiration expires
        if numResolvers == 0
          if !includeBound then break else return { rune, nonce, expired }
        else if !best.numResolvers? || numResolvers < best.numResolvers
          best = { numResolvers, tuple: { rune, nonce, resolvers: grantResolvers } }
      else
        expired.push { rune, nonce }
    return { best.tuple..., expired }

store = ({ rune, nonce }) ->
  [ { identity, domain, grants, resolvers, expires } ] = JSON64.decode rune
  if (data = localStorage.getItem identity)?
    _identity = JSON.parse data
  else
    _identity = {}
  _identity[ domain ] ?= []
  numResolvers = if resolvers? then ( Object.keys resolvers ).length else 0
  for grant in grants
    bundle =
      methods: {}
    if grant.resolvers?
      grantResolvers = {}
      for resolver in grant.resolvers
        grantResolvers[ resolver ] = resolvers[ resolver ]
    if grant.resources.exclude?
      bundle.exclude = grant.resources.exclude
    else 
      bundle.include = grant.resources.include ? grant.resources
    for method in grant.methods
      bundle.methods[ method ] = { rune, nonce, expires, numResolvers, grantResolvers }
    _identity[ domain ].push bundle
  localStorage.setItem identity, JSON.stringify _identity
  null

lookup = ({ identity, domain, resource, method }, { includeBound = true } = {}) ->
  if (data = localStorage.getItem identity)?
    _identity = JSON.parse data
    if _identity[ domain ]?
      candidates = getCandidateRunes resource, method, _identity[ domain ]
      { rune, nonce, resolvers, expired } = bestMatch candidates, includeBound
      if rune? && nonce?
        for item in expired
          _identity[ domain ] = removeRune { rune: item.rune, nonce: item.nonce }, _identity[ domain ]
        localStorage.setItem identity, JSON.stringify _identity
        resources = []
        if resolvers?
          for key, resolver of resolvers
            resources = [ resources..., ( getResolverResources resolver )... ]
        return { credential: { rune, nonce }, resources }

has = ( query ) -> ( lookup query )?

hasGrant = ( rune, query ) ->
  { resource, method } = query
  [ { identity, domain, grants, resolvers, expires } ] = JSON64.decode rune
  query.domain == domain && 
    grants.some ( grant ) ->
      if grant.resources.exclude?
        if !( resource in grant.resources.exclude ) && ( method in grant.methods )
          return true
      else
        resources = grant.resources.include ? grant.resources
        if ( resource in resources ) && ( method in grant.methods )
          return true
      return false

remove = ({ identity, domain, rune, nonce }) ->
  if ( data = localStorage.getItem identity )?
    _identity = JSON.parse data
    if _identity[ domain ]?
      _identity[ domain ] = removeRune { rune, nonce }, _identity[ domain ]
      localStorage.setItem identity, JSON.stringify _identity
null

export { store, lookup, has, remove, hasGrant }