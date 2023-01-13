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

removeExpired = ( runes, expired ) ->
  runes = runes.filter ( tuple ) ->
    deleted = expired.some ( item ) ->
      Val.equal item, tuple
    !deleted

getCandidateRunes = ( resource, method, grants ) ->
  candidates = []
  for grant in grants
    if grant.exclude?
      if !( resource in grant.exclude ) && grant[ method ]?
        candidates.push grant[ method ]
    else if grant.include? && grant[ method ]?
      if ( resource in grant.include )
        candidates.push grant[ method ]
  candidates

bestMatch = ( runes ) ->
  if runes?
    expired = []
    best = {}
    for tuple in runes
      { rune, nonce, expires, numResolvers, grantResolvers } = tuple
      if checkExpiration expires
        if numResolvers == 0
          removeExpired runes, expired
          return { rune, nonce }
        else if !best.numResolvers? || numResolvers < best.numResolvers
          best = { numResolvers, tuple: { rune, nonce, resolvers: grantResolvers } }
      else
        expired.push tuple
    removeExpired runes, expired
    return best.tuple

store = ({ rune, nonce }) ->
  [ { identity, domain, grants, resolvers, expires } ] = JSON64.decode rune
  if (data = localStorage.getItem identity)?
    _identity = JSON.parse data
  else
    _identity = {}
  _identity[ domain ] ?= []
  numResolvers = if resolvers? then ( Object.keys resolvers ).length else 0
  for grant in grants
    bundle = {}
    if grant.resolvers?
      grantResolvers = {}
      for resolver in grant.resolvers
        grantResolvers[ resolver ] = resolvers[ resolver ]
    if grant.resources.exclude?
      bundle.exclude = grant.resources.exclude
    else 
      bundle.include = grant.resources.include ? grant.resources
    for method in grant.methods
      bundle[ method ] = { rune, nonce, expires, numResolvers, grantResolvers }
    _identity[ domain ].push bundle
  localStorage.setItem identity, JSON.stringify _identity
  null

lookup = ({ identity, domain, resource, method }) ->
  if (data = localStorage.getItem identity)?
    _identity = JSON.parse data
    if _identity[ domain ]?
      candidates = getCandidateRunes resource, method, _identity[ domain ]
      if ( result = bestMatch candidates )?
        { rune, nonce, resolvers } = result
        resources = []
        if resolvers?
          for key, resolver of resolvers
            resources = [ resources..., ( getResolverResources resolver )... ]
        return { credential: { rune, nonce }, resources }

has = ( query ) -> ( lookup query )?

export { store, lookup, has }