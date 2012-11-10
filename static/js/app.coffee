######## BASE STUFF ########
RestModel = Backbone.Model.extend
	idAttribute: '_id'
	id: ''
	initialize: -> _.bindAll @, 'url'
	url: -> "/#{@path}/#{@id}"

AppRouter = Marionette.AppRouter.extend
	initialize: (options) ->
		@app = options

ItemView = Marionette.ItemView.extend
	initialize: ->
		_.bindAll @, 'render'
		@model.on 'change', @render

######## USER STUFF ########
User = RestModel.extend
	path: 'users'

UserRouter = AppRouter.extend
	routes:
		'@:username': 'read'
		'user/:username': 'read'
	read: (username) ->
		console.log username

######## RECIPE STUFF ########
Recipe = RestModel.extend
	path: 'recipes'

RecipeRouter = AppRouter.extend
	routes:
		':username/:id': 'read'
		'/*': 'read'
	read: (username, id) ->
		#model = new Recipe
		#	username: username
		#	id: id
		#model.fetch()
		model = new Recipe
			id: '123456'
			author:
				username: 'mappum'
				avatar: 'http://placehold.it/128x128'
				userId: '0'
			title: 'Mushroom Stew'
			image: 'http://www.applecrumbles.com/wp-content/uploads/2009/11/DSC_2263.jpg'
			description: 'Mushrooms. Boil \'em, mash \'em, stick \'em in a stew. Bla bla bla bla ofgihd dsgoihj gjfdg gj dfgjo text about mushroom stew.\n\nSomethign else.'
			ingredients: [
				'3 Tablespoons olive oil'
				'2 medium onions, chopped'
				'3 garlic cloves, minced'
				'1 pound cremini mushrooms, cleaned and roughly chopped'
				'1 pound shiitake mushrooms, stemmed, cleaned, and caps roughly chopped'
				'1/2 pound red-skinned potatoes, such as Red Bliss or All Reds, cut into 1/2-inch pieces'
				'1/2 pound yellow-fleshed potatoes, such as Austrian Crescent or Yukon Gold, cut into 1/2-inch pieces'
				'1 Tablespoon minced fresh rosemary'
				'1 Tablespoon minced fresh sage'
				'1 Tablespoon fresh thyme'
				'2 cups mushroom or vegetable stock'
				'1/2 cup chopped fresh parsley'
				'1 teaspoon salt'
				'1/2 teaspoon freshly ground black pepper'
			]
			steps: [
				'Heat a large pot over medium-high heat. Swirl in the olive oil, then add the onions and cook until soft and fragrant, about 4 minutes, stirring often. Add the garlic and cook for 30 seconds. Stir in the cremini and shiitake mushrooms. Cook just until the mushrooms begin to give off their liquid, about 3 minutes, stirring frequently. '
				'Stir in both red potatoes and gold potatoes with a wooden spoon, then add the rosemary, sage, and thyme. Cook just until aromatic, about 30 seconds. Stir in the stock, cover, and reduce the heat to low. Simmer until the potatoes are soft when pierced with a fork, about 12 minutes. Gently stir in the parsley, salt, and pepper and cook for another 2 minutes to bind the flavors. '
				'Serve immediately. The soup can be made in advance -- store it covered in the refrigerator for up to three days, but thin it out with extra stock as you reheat it.'
				'The stew can be varied with a seemingly limitless list of mushrooms. Substitute hedgehog, lobster, black trumpet, porcini, portobello, or hen of the woods, so long as you have a total of 2 pounds.',
			]
			origin:
				id: '123455'
				title: 'Crappy Mushroom Stew'
				author:
					username: 'kepzorz'

		@app.mainRegion.show new RecipeView {model: model}

RecipeView = ItemView.extend
	template: '#template-recipe'
	tagName: 'div'
	className: 'row-fluid recipe'

######## SESSION STUFF ########
Session = Backbone.Model.extend
	initialize: (options) ->
		#TODO: check session state
		this.set 'user', new User {username: 'mappum', avatar: 'http://placehold.it/128x128'}

NavbarView = Marionette.ItemView.extend
	tagName: 'div'
	className: 'navbar'
	template: '#template-navbar'

######## APP STUFF ########
App = new Marionette.Application

App.addInitializer (options) ->
	App.session = new Session

	App.addRegions
		mainRegion: '#main'
		navbarRegion: '#navbar'

	App.navbarView = new NavbarView {model: App.session}
	App.navbarRegion.show App.navbarView

	new UserRouter App
	new RecipeRouter App

	Backbone.history.start()

$ -> App.start()
