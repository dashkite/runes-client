import { JSON36 } from "./helpers"

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

store = ({ rune, nonce }) ->
  [ { identity, domain, grants, resolvers } ] = JSON36.decode rune
  if (data = localStorage.getItem identity)?
    _identity = JSON.parse data
  else
    _identity = {}
  _identity[ domain ] ?= {}
  _identity[ domain ][ "grants" ] = []
  _identity[ domain ][ "resolvers" ] = {}
  for key, resolver of resolvers
    resources = []
    resourcesFind resolver, resources
    _identity[ domain ][ "resolvers" ][ key ] = { resources }
  for grant in grants
    bundle = {}
    if grant.resolvers?
      bundle.resolvers = grant.resolvers
    if grant.resources.exclude?
      bundle.exclude = grant.resources.exclude
    else 
      bundle.include = grant.resources.include ? grant.resources
    for method in grant.methods
      bundle[ method ] = { rune, nonce }
    _identity[ domain ][ "grants" ].push bundle
  localStorage.setItem identity, JSON.stringify _identity
  null

lookup = ({ identity, domain, resource, method }) ->
  if (data = localStorage.getItem identity)?
    _identity = JSON.parse data
    if _identity[ domain ]?
      for grant in _identity[ domain ][ "grants" ]
        checkResource = false
        if grant.exclude?
          if !( resource in grant.exclude )
            checkResource = true
        else if grant.include?
          if ( resource in grant.include )
            checkResource = true
        if checkResource
          if ( result = grant[ method ])?
            resources = []
            if grant.resolvers?
              for resolver in grant.resolvers
                resources = resources.concat _identity[ domain ][ "resolvers" ][ resolver ].resources
            return { credential: result, resources }

has = ( query ) -> ( lookup query )?

export { store, lookup, has }