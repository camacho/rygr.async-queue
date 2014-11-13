# ------------------------------------------------------------------------------
# Load in modules
# ------------------------------------------------------------------------------
gulp = require 'gulp'
$ = require('gulp-load-plugins')()

runSequence = require 'run-sequence'

config = dirs: require './config/dirs'
pjson = require('./package.json')

context =
  ENV: process.env.NODE_ENV or 'development'
  VERSION: pjson.version
  YEAR: new Date().getFullYear()
  AUTHOR: pjson.author
  LICENSE: pjson.license
  REPO: pjson.repository.url

# ------------------------------------------------------------------------------
# Custom vars and methods
# ------------------------------------------------------------------------------
alertError = $.notify.onError (error) ->
  message = error?.message or error?.toString() or 'Something went wrong'
  "Error: #{ message }"

# ------------------------------------------------------------------------------
# Compile assets
# ------------------------------------------------------------------------------
gulp.task 'compile', ->
  gulp.src("#{ config.dirs.src }/**/*.coffee")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.preprocess context: context)
    .pipe($.coffeelint optFile: './.coffeelintrc')
    .pipe($.coffeelint.reporter())
    .pipe($.coffee bare: false, sourceMap: false)
    .pipe(gulp.dest config.dirs.dest)
    .pipe($.browserify())
    .pipe($.rename (path) ->
      path.basename += '.browser'
      undefined
    )
    .pipe(gulp.dest config.dirs.dest)

gulp.task 'minify', ->
  gulp.src([
    "#{config.dirs.dest}/rygr.async-queue.js"
    "#{config.dirs.dest}/rygr.async-queue.browser.js"
  ])
    .pipe($.uglify preserveComments: 'all')
    .pipe($.rename (path) ->
      path.basename += '.min'
      undefined
    )
    .pipe(gulp.dest config.dirs.dest)

# ------------------------------------------------------------------------------
# Build
# ------------------------------------------------------------------------------
gulp.task 'build', (cb) ->
  runSequence 'compile', cb

# ------------------------------------------------------------------------------
# Release
# ------------------------------------------------------------------------------
(->
  bump = (type) ->
    (cb) ->
      gulp.src(['./package.json', './bower.json'])
        .pipe($.bump type: type)
        .pipe(gulp.dest './')
        .on 'end', -> runSequence 'build', cb
      undefined

  publish = (type) ->
    (cb) ->
      sequence = [if type then "bump:#{ type }" else 'build']
      sequence.push 'minify'
      sequence.push ->
        spawn = require('child_process').spawn
        spawn('npm', ['publish'], stdio: 'inherit').on 'close', cb

      runSequence sequence...

  for type, index in ['prerelease', 'patch', 'minor', 'major']
    gulp.task "bump:#{ type }", bump type
    gulp.task "publish:#{ type }", publish type

  gulp.task 'bump', bump 'patch'
  gulp.task 'publish', publish()
)()

# ------------------------------------------------------------------------------
# Watch
# ------------------------------------------------------------------------------
gulp.task 'watch', ->
  gulp.watch "#{ config.dirs.src }/**/*.coffee", ['compile']

# ------------------------------------------------------------------------------
# Default
# ------------------------------------------------------------------------------
gulp.task 'default', ->
  runSequence 'build', 'watch'
