models = require '../models'
User = models.User
crypto = require 'crypto'
config = require(__dirname + '/../config.coffee')

setUser = (user) ->
	if user
		this.session.userId = user._id
		this.session.user = 
			_id: user._id
			username: user.username
			email: user.email
			avatar: user.avatar
		this.session.save()
	else
		this.session.user = undefined
		this.session.userId = undefined
		this.session.destroy()

auth = module.exports = 
	middleware: (req, res, next) ->
		req.setUser = setUser.bind req
		next()

