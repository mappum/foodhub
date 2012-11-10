controllers = require './controllers'
recipes = controllers.recipes

requireLogin = (req, res, next) ->
	if req.session.userId? then next() else res.error(401)

module.exports = (app) ->
	app.get '/recipes/:recipe', recipes.read
	app.post '/recipes/:recipe', requireLogin, recipes.create
	app.put '/recipes/:recipe', requireLogin, recipes.update
	app.delete '/recipes/:recipe', requireLogin, recipes.update