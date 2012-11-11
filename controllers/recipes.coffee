models = require '../models'
Recipe = models.Recipe

recipes = module.exports =

	create: (req, res)->
		console.log req.body, req.session.user.username
		new Recipe(
			title: req.body.title
			description: req.body.description
			ingredients: req.body.ingredients
			instructions: req.body.instructions
			picture: req.body.picture
			author: req.session.user.username

		).save res.mongo

	fork: (req, res) ->
		Recipe.findOne 
			'_id': req.params.recipe 
			, (err, doc)->
				if err then res.error(401)
				else
					console.log doc
					new Recipe(
						title: doc.title
						description: doc.description
						ingredients: doc.ingredients
						instructions: doc.instructions
						picture: doc.picture
						author: req.session.user.username
						origin: 
							id: doc._id
							author: doc.author
							title: doc.title

					).save res.mongo
	read: (req, res) ->
		Recipe.findOne
			'_id': req.params.recipe,
			res.mongo
	update: (req, res) ->
		Recipe.findById req.params._id, (err, doc)->
			if doc.username isnt req.session.user.username then res.error(401) 
			else 
				if req.body.title? then doc.title = req.body.title
				if req.body.description? then doc.description = req.body.description
				if req.body.ingredients? then doc.ingredients = req.body.ingredients
				if req.body.instructions? then doc.instructions = req.body.instructions
				if req.body.picture? then doc.picture = req.body.picture
			doc.save res.mongo
	delete: (req, res) ->
		Recipe.remove 
			'_id': req.params._id
			'username': req.session.user.username
		, res.mongo
	





