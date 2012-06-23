express = require 'express'
browserify = require 'browserify'
lessMiddleware = require 'less-middleware'

app = express.createServer()

bundle = browserify
  entry: "#{__dirname}/assets/javascripts/entry.coffee"
  watch: process.env.NODE_ENV != 'production'
  debug: true

if !process.env.NODE_ENV || process.env.NODE_ENV == "development"
  growl = require 'growl'
  bundle.on 'bundle', =>
    growl "JavaScript rebundled", title: "Browserify"

app.configure ->
  app.use lessMiddleware
    src: "#{__dirname}/assets"
    dest: "#{__dirname}/public"
    compress: true
    once: process.env.NODE_ENV in ['staging', 'production']
  app.use bundle
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session secret: 'abcdefghijklmnopqrstuvwxyz1234567890'
  app.use app.router
  app.use express.static(__dirname + '/public')

  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'jade'

app.all '*', (req, res, next) ->
  res.local 'title', ''
  next()

app.get '/', (req, res) ->
  res.render 'index'

app.listen 3000, ->
  console.log "Server listening on port 3000 in #{process.env.NODE_ENV || 'development'} mode"
