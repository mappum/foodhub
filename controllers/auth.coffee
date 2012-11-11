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
	checkPassword: checkPassword