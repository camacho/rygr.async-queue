###
Rygr Async Queue, v /* @echo VERSION */
Copyright (c)/* @echo YEAR */ /* @echo AUTHOR */
Distributed under /* @echo LICENSE */ license
/* @echo REPO */
###

Q = require 'q'

module.exports = (args, callbacks, done) ->
  stack = []
  
  isArray = Array.isArray or
  (obj) -> Object::toString.call(obj) is '[object Array]'
  
  isFunction = (obj) -> typeof obj is 'function'

  flow = Q.defer()
  args = [args] unless isArray args
  baseArity = args.length + 1

  unless isArray callbacks
    if isFunction callbacks
      callbacks = [callbacks]
    else
      throw new Error 'Callbacks must be an array of functions'

  for callback in callbacks
    if isFunction callback
      stack.push {handle: callback}
    else
      throw new Error 'Callback is not a function'

  handle = ->
    index = 0

    next = (err) ->
      return unless Q.isPending flow.promise

      layer = stack[index++]

      unless layer
        if err then flow.reject err else flow.resolve()
        done? err
        return

      try
        arity = layer.handle.length

        if err
          if arity is baseArity + 1
            layer.handle.apply undefined, [err].concat args, [next]
          else
            next err
        else if arity < baseArity + 1
          layer.handle.apply undefined, args.concat [next]
        else
          next()

      catch e
        next e

    next()

  handle()

  flow.promise
