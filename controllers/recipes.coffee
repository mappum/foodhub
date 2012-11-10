models = require '../models'
Recipe = models.Recipe

module.exports =
	read: (req, res) ->
		Recipe.findOne
			'author.username': req.params.author
			'url': req.params.recipe,
			res.json