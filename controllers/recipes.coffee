models = require '../models'
Recipe = models.Recipe

module.exports =
	read: (req, res) ->
		Recipe.findOne
			'username': req.params.author
			'url': req.params.recipe,
			res.mongo