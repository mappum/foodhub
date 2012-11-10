express = require 'express'
mongoose = require 'mongoose'
config = require './config'

app = express()
mongoose.connect config.mongoUri

app.use express.static './static'

app.use (req, res, next) ->
	res.error = (code, err) ->
		if not err? then err = code
		res.json code or 500, {error: err}

	res.mongo = (err, doc) ->
		if err then res.error err
		else res.json doc

	next()

require('./routes') app

app.listen config.port