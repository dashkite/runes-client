import { JSON36 } from "./helpers"

store = ({ rune, nonce }) ->
  [ { identity, domain, grants, scope } ] = JSON36.decode rune
  if (data = localStorage.getItem identity)?
    _identity = JSON.parse data
  else
    _identity = {}
  _identity[ domain ] ?= []
  for grant in grants
    if grant.resources.exclude?
      bundle = {}
      bundle.exclude = grant.resources.exclude
      for method in grant.methods
        { bindings } = grant
        bundle[ method ] ?= []
        bundle[ method ].push { rune, nonce, bindings, scope }
      _identity[ domain ].push bundle
    else 
      if grant.resources.include?
        grant.resources = grant.resources.include
      bundle = {}
      bundle.include = grant.resources
      for method in grant.methods
        { bindings } = grant
        bundle[ method ] ?= []
        bundle[ method ].push { rune, nonce, bindings, scope }
      _identity[ domain ].push bundle
  localStorage.setItem identity, JSON.stringify _identity
  null

lookup = ({ identity, domain, resource, bindings, method }) ->
  if (data = localStorage.getItem identity)?
    _identity = JSON.parse data
    if _identity[ domain ]?
      for grant in _identity[domain]
        if grant.exclude?
          if !( resource in grant.exclude )
            if ( results = grant[ method ])?
              for result in results
                if result.scope?
                  if bindings[result.scope] == result.bindings[result.scope]
                    return result
                else
                  return result
        else if grant.include?
          if ( resource in grant.include )
            if ( results = grant[ method ])?
              for result in results
                if result.scope?
                  if bindings[result.scope] == result.bindings[result.scope]
                    return result
                else
                  return result

has = ( query ) -> ( lookup query )?

export { store, lookup, has }