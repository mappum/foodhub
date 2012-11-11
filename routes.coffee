controllers = require './controllers'
recipes = controllers.recipes
users = controllers.users
auth = controllers.auth

requireLogin = (req, res, next) ->
	if req.session.userId? then next() else res.error 401, 'not logged in'

requireLogout = (req, res, next) ->
	if not req.session.userId? then next() else res.error 401, 'should be logged out'

module.exports = (app) ->
	app.get '/recipes/:recipe', recipes.read
	app.post '/recipes/', requireLogin, recipes.create
	app.put '/recipes/:recipe', requireLogin, recipes.update
	app.delete '/recipes/:recipe/', requireLogin, recipes.update
	app.post '/recipes/:recipe/fork'

	app.get '/users/:username', users.read
	app.post '/users', users.create

	app.post '/auth', requireLogout, auth.login
	app.get '/logout', auth.logout


	# catch invalid paths
	app.get '*', (req, res) ->
		res.redirect "/##{req.path}"
	app.all '*', (req, res) ->
		res.error 404
