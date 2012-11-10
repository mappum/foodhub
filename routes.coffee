controllers = require './controllers'
recipes = controllers.recipes

module.exports = (app) ->
	app.get '/:author/:recipe', recipes.read
