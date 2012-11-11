express = require 'express'
mongoose = require 'mongoose'
config = require './config'
RedisStore = require('connect-redis') express
sessionStore = new RedisStore(config.redis)

app = express()
mongoose.connect config.mongoUri

app.use express.compress()
app.configure 'development', ->	
	app.use express.errorHandler
		dumpExceptions: true
		showStack: true
app.use express.static './static'
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.cookieSession
	store: sessionStore
	secret: config.session.cookie.secret
	key: config.session.cookie.key
	cookie:
		maxAge: config.session.cookie.maxAge

app.use (req, res, next) ->
	res.error = (code, err) ->
		if not err?
			err = code
			code = 500
		res.json code, {error: err}

	res.mongo = (err, doc) ->
		if err then res.error 500, 'An error occurred.'
		else res.json doc

	next()
app.use(require(__dirname + '/controllers/auth.coffee').middleware)
require('./routes') app

app.listen config.port