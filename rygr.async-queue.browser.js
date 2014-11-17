
/*
Rygr Async Queue, v 1.1.0
Copyright (c)2014 Patrick Camacho
Distributed under MIT license
https://github.com/camacho/rygr.async-queue
 */

(function() {
  var factory;

  factory = function(PromiseLib) {
    var isArray, isFunction;
    if (!PromiseLib) {
      throw new ReferrenceError('Promise library is not defined');
      return;
    }
    isArray = Array.isArray || function(obj) {
      return Object.prototype.toString.call(obj) === '[object Array]';
    };
    isFunction = function(obj) {
      return typeof obj === 'function';
    };
    return function(args, callbacks, done) {
      var baseArity, callback, flow, handle, stack, _i, _len;
      stack = [];
      flow = (PromiseLib.defer || PromiseLib.Deferred)();
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
          if (!((typeof PromiseLib.isPending === "function" ? PromiseLib.isPending(flow.promise) : void 0) || flow.state() === 'pending')) {
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
      return flow;
    };
  };

  (function(root, factory) {
    var AsyncQueue, PromiseLib;
    PromiseLib = 'jquery';
    if (typeof define === 'function' && define.amd) {
      return define([PromiseLib], function(dep) {
        return factory(dep);
      });
    } else if (typeof exports !== 'undefined') {
      AsyncQueue = factory(require(PromiseLib));
      if (typeof module !== 'undefined' && module.exports) {
        return module.exports = AsyncQueue;
      } else {
        return exports.AsyncQueue = AsyncQueue;
      }
    } else {
      return root.AsyncQueue = factory(root[PromiseLib]);
    }
  })(this, factory);

}).call(this);
