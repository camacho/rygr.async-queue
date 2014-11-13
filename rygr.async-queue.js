
/*
Rygr Async Queue, v 0.0.3
Copyright (c)2014 Patrick Camacho
Distributed under MIT license
https://github.com/camacho/rygr.async-queue
 */

(function() {
  var Q;

  Q = require('q');

  module.exports = function(args, callbacks, done) {
    var baseArity, callback, flow, handle, isArray, isFunction, stack, _i, _len;
    stack = [];
    isArray = Array.isArray || function(obj) {
      return Object.prototype.toString.call(obj) === '[object Array]';
    };
    isFunction = function(obj) {
      return typeof obj === 'function';
    };
    flow = Q.defer();
    if (!isArray(args)) {
      args = [args];
    }
    baseArity = args.length + 1;
    if (!isArray(callbacks)) {
      if (isFunction(callbacks)) {
        callbacks = [callbacks];
      } else {
        throw new Error('Callbacks must be an array of functions');
      }
    }
    for (_i = 0, _len = callbacks.length; _i < _len; _i++) {
      callback = callbacks[_i];
      if (isFunction(callback)) {
        stack.push({
          handle: callback
        });
      } else {
        throw new Error('Callback is not a function');
      }
    }
    handle = function() {
      var index, next;
      index = 0;
      next = function(err) {
        var arity, e, layer;
        if (!Q.isPending(flow.promise)) {
          return;
        }
        layer = stack[index++];
        if (!layer) {
          if (err) {
            flow.reject(err);
          } else {
            flow.resolve();
          }
          if (typeof done === "function") {
            done(err);
          }
          return;
        }
        try {
          arity = layer.handle.length;
          if (err) {
            if (arity === baseArity + 1) {
              return layer.handle.apply(void 0, [err].concat(args, [next]));
            } else {
              return next(err);
            }
          } else if (arity < baseArity + 1) {
            return layer.handle.apply(void 0, args.concat([next]));
          } else {
            return next();
          }
        } catch (_error) {
          e = _error;
          return next(e);
        }
      };
      return next();
    };
    handle();
    return flow.promise;
  };

}).call(this);
