Async Queue
------
```coffee
asyncQueue = require 'rygr.async-queue'
```
Async queue allows you to assemble a series of asynchronous methods to be run in a sequence. This is inspired by Express' middleware feature.

### Require
```coffee
asyncQueue = require 'rygr.async-queue'
```

or, in JavaScript

```js
asyncQueue = require('rygr.async-queue')
```

### Arguments
Async queue takes three arguments:

* Args **Array|null** *(required)*
  An array of arguments to be passed to each method in the queue
* Queue *Array<Functions>** *(required)*
  An array of functions to be called in sequence. Each function will receive the arguments passed in and an extra `next` function to trigger the next function in the queue (required). An error function can be included and is expected to take an extra argument.
* Done **Function** *(optional)*
  A callback function to be executed when the sequence completes or is short-circuited because of an error. It will receive an error as it's first argument if one occured, or null otherwise.

### Useage
```coffee
asyncQueue = require 'rygr.async-queue'

first = (name, next) ->
  console.log "#{ name }: first!"
  next()

# Throwing an error (or calling next with an error) will cause the queue to skip
# to the error function or skip to call done if none is provided
second = (name, next) ->
  throw new Error 'Uhoh!'

# This function will be skipped since second threw an error
third = (name, next) ->
  console.log "#{ name }: third!"

# The queue will know this is an error method since it takes an extra argument
errorHandler = (error, name, next) ->
  console.log error.message
  next error

# This function will be called last after all the queue has been exhausted
done = (error) ->
  console.log if error then  "Something went wrong." else "Success!"

# Call asyncQueue with the args, function queue, and done function
asyncQueue(['Test'], [
  first
  second
  third
  errorHandler
], done)

# Output:
# Test: first!
# Uhoh!
# Something went wrong.
```

Development
---
```shell
# From the project's dir
npm install && bower install
```

Build tool
---
This project uses Gulp.js for it's build tool

To build:
```shell
gulp build
```

To run tests:
```shell
gulp test
```

To build, run tests, and watch for changes:
```shell
gulp
```
