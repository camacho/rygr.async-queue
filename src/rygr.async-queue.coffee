###
Rygr Async Queue, v /* @echo VERSION */
Copyright (c)/* @echo YEAR */ /* @echo AUTHOR */
Distributed under /* @echo LICENSE */ license
/* @echo REPO */
###

factory = (PromiseLib) ->
  unless PromiseLib
    throw new ReferrenceError 'Promise library is not defined'
    return

  isArray = Array.isArray or
  (obj) -> Object::toString.call(obj) is '[object Array]'

  isFunction = (obj) -> typeof obj is 'function'

  (args, callbacks, done) ->
    stack = []

    flow = (PromiseLib.defer or PromiseLib.Deferred)()
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
        unless PromiseLib.isPending?(flow.promise) or flow.state() is 'pending'
          return

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

    flow

((root, factory) ->
  # Set up Rygr.AsyncQueue

  # AMD
  if typeof define is 'function' and define.amd
    define ['/* @echo PROMISELIB */'], (dep) ->
      factory dep

  # Node.js/CommonJS
  else if typeof exports isnt 'undefined'
    AsyncQueue = factory require '/* @echo PROMISELIB */'

    if typeof module isnt 'undefined' and module.exports
      module.exports = AsyncQueue
    else
      exports.AsyncQueue = AsyncQueue

  # Global
  else
    root.AsyncQueue = factory root./* @echo PROMISELIB */
)(@, factory)
