models = require '../models'
User = models.User
crypto = require 'crypto'
config = require(__dirname + '/../config.coffee')

checkPassword = (user, pass, success, failure) ->
	query = {}
	if user.indexOf('@') isnt -1 then query.email = user else query.username = user
	User.findOne query, (err, doc)->
		if err or not doc then failure()
		else
			hash = crypto.createHash 'sha256'
			hash.update pass
			hash.update new Buffer(doc.password.salt, 'hex')
			if hash.digest('hex') is doc.password.hash then success doc
			else
				failure()


setUser = (user) ->
	if user?
		this.session.userId = user._id
		this.session.user = 
			_id: user._id
			username: user.username
			email: user.email
			avatar: user.avatar
	else
		this.session = null

auth = module.exports = 
	middleware: (req, res, next) ->
		req.setUser = setUser.bind req
		next()
	checkPassword: checkPassword
	login: (req, res) ->
		checkPassword req.body.user, req.body.password, (user) ->
			req.setUser user

			res.json req.session.user
		, ()->
			res.error 400
	logout: (req, res) ->
		req.setUser null
		res.redirect '/'
	getState: (req, res) ->
		res.json req.session.user
