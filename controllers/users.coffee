models = require '../models'
User = models.User
crypto = require 'crypto'
gravatar = require 'gravatar'
config = require(__dirname + '/../config.coffee')

module.exports = 
	create: (req, res) ->
		if req.body.password.length < 6 
			res.error(400)
			return
		hash = crypto.createHash 'sha256'
		salt = crypto.randomBytes 32
		hash.update req.body.password
		hash.update salt

		user = new User
			username: req.body.username
			email: req.body.email
			avatar: gravatar.url(req.body.email,
				s: 200
				d: 'mm'
			)
			password:
				hash: hash.digest 'hex'
				salt: salt.toString 'hex'

		console.log req
		req.session.regenerate (err)->
			if err then res.error(500)
			else
				req.setUser
				user.save res.mongo
	read: (req, res) ->
		User.find 
			username: req.params.username
		, res.mongo
	update: (req, res) ->
		#TODO: allow user to change their information
	delete: (req, res) ->
		#TODO: allow account deletion

		
