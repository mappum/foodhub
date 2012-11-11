######## BASE STUFF ########
RestModel = Backbone.Model.extend
	idAttribute: '_id'
	id: ''
	initialize: -> _.bindAll @, 'url'
	url: -> "/#{@path}/#{@id}"

AppRouter = Marionette.AppRouter.extend
	initialize: (options) ->
		@app = options
		_.bindAll @, 'navigate'
	navigate: (view) ->
		@app.mainRegion.show view
		@app.restoreScrollState()

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

######## RECIPE STUFF ########
Recipe = RestModel.extend
	path: 'recipes'

RecipeRouter = AppRouter.extend
	routes:
		'recipe/:id': 'read'
	read: (id) ->
		if id != 'test'
			model = new Recipe
				_id: id
			model.fetch()
		else
			model = new Recipe
				id: id
				author: 'mappum'
				title: 'Mushroom Stew'
				picture: 'http://www.applecrumbles.com/wp-content/uploads/2009/11/DSC_2263.jpg'
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
				instructions: [
					'Heat a large pot over medium-high heat. Swirl in the olive oil, then add the onions and cook until soft and fragrant, about 4 minutes, stirring often. Add the garlic and cook for 30 seconds. Stir in the cremini and shiitake mushrooms. Cook just until the mushrooms begin to give off their liquid, about 3 minutes, stirring frequently. '
					'Stir in both red potatoes and gold potatoes with a wooden spoon, then add the rosemary, sage, and thyme. Cook just until aromatic, about 30 seconds. Stir in the stock, cover, and reduce the heat to low. Simmer until the potatoes are soft when pierced with a fork, about 12 minutes. Gently stir in the parsley, salt, and pepper and cook for another 2 minutes to bind the flavors. '
					'Serve immediately. The soup can be made in advance -- store it covered in the refrigerator for up to three days, but thin it out with extra stock as you reheat it.'
					'The stew can be varied with a seemingly limitless list of mushrooms. Substitute hedgehog, lobster, black trumpet, porcini, portobello, or hen of the woods, so long as you have a total of 2 pounds.',
				]
				origin:
					id: '123455'
					title: 'Crappy Mushroom Stew'
					author: 'kepzorz'

		@navigate new RecipeView {model: model, session: @app.session}

RecipeView = ItemView.extend
	template: '#template-recipe'
	tagName: 'div'
	className: 'container-fluid recipe'
	events:
		'mouseenter .editable': 'edit'

	initialize: (options) ->
		# TODO: reorganize? it's kind of hacky to put the session in the model
		@model.set 'session', options.session
		_.bindAll @, 'render'
		@model.on 'change', @render

	edit: (e) ->
		parent = $ e.target
		if parent.hasClass('editing') or parent.prop('tagName') is 'TEXTAREA' then return
		parent.addClass 'editing'

		originalText = parent.text().replace(/[\n\r]+/g, ' ').trim()

		child = $ document.createElement 'textarea'
		child.attr 'rows', '1'
		child.attr 'placeholder', 'Click to edit'
		child.val originalText
		child.css
			'color': parent.css 'color'
			'font': parent.css 'font'
			'line-height': parent.css 'line-height'
			'padding': parent.css 'padding'
			'margin': parent.css 'margin'
			'height': parent.height()
			'width': parent.width()
		child.keydown (e) =>
			if e.which is 13
				e.preventDefault()
				if parent.prop('tagName') is 'LI'
					text = child.val()
					before = text.substr 0, child.get(0).selectionStart
					after = text.substr child.get(0).selectionEnd

					newEl = $ document.createElement 'li'
					newEl.attr 'class', parent.attr 'class'
					newEl.removeClass 'editing'
					newEl.removeClass 'focused'
					newEl.mouseenter @edit

					newEl.text before
					child.val after

					child.setCursorPosition(0);

					newEl.insertBefore parent
		unedit = (e) =>
			if parent.hasClass 'focused' then return
			text = child.val().trim()
			if not text and parent.prop('tagName') is 'LI' and parent.parent().find('li').length > 1
				return parent.remove()
			parent.empty().text text
			parent.removeClass 'editing'
			if originalText != text
				@trigger 'edit', {el: parent, text: text}
		child.mouseleave unedit
		child.focus (e) ->
			parent.addClass 'focused'
			@$el.find('.editable').removeClass 'editable'
			parent.addClass 'editable'
		child.blur (e) ->
			parent.removeClass 'focused'
			unedit()
		parent.empty().append child

######## SESSION STUFF ########
Session = Backbone.Model.extend
	initialize: (options) ->
		@set 'loggedIn', false
		@getState()
		_.bindAll @, 'getState', 'login', 'register'

	getState: (data, callback) ->
		user = new User
		user.url = '/auth'
		user.fetch
			success: (res) =>
				if callback? then callback null
				@set 'user', user
				@set 'loggedIn', true
				@trigger 'change', user
			error: callback

	login: (data, callback) ->
		$.ajax
			url: '/auth'
			type: 'POST'
			data: data
			success: (res) =>
				if callback? then callback null
				@getState()
			error: callback

	register: (data, callback) ->
		$.ajax
			url: '/users'
			type: 'POST'
			data: data
			success: ->
				if callback? then callback null
			error: callback

NavbarView = ItemView.extend
	tagName: 'div'
	className: 'navbar'
	template: '#template-navbar'
	events:
		'click fieldset.login .submit': 'login'
		'click fieldset.login': 'noClick'
		'keypress fieldset.login': 'onKey'
	login: (e) ->
		login = @$el.find 'fieldset.login'
		@model.login
			user: login.find('.user').val()
			password: login.find('.password').val()
	noClick: (e) ->
		e.preventDefault()
		return false
	onKey: (e) ->
		if e.which is 13 then @$el.find('fieldset.login .submit').trigger 'click'

######## PAGE STUFF ########
FrontPageView = Marionette.ItemView.extend
	tagName: 'div'
	className: 'front container-fluid'
	template: '#template-front'

RegisterPageView = Marionette.ItemView.extend
	tagName: 'div'
	className: 'register span6 centered'
	template: '#template-register'
	events:
		'click .submit': 'register'
	register: ->
		@model.register
			email: @$el.find('.email').val()
			password: @$el.find('.password').val()
			username: @$el.find('.username').val(), (err, doc) ->


PageRouter = AppRouter.extend
	routes:
		'register': 'register'
		'/': 'front'
		'/*': 'front'
	front: -> @navigate new FrontPageView {model: @app.session}
	register: -> @navigate new RegisterPageView {model: @app.session}

######## APP STUFF ########
Application = Marionette.Application.extend
	saveScrollState: ->
		@scrollStates[window.location.hash] = $(document).scrollTop()

	restoreScrollState: ->
		scroll = 0
		if @scrollStates[window.location.hash]?
			scroll = @scrollStates[window.location.hash]
			@scrollStates[window.location.hash] = null
		$(document).scrollTop scroll

app = new Application
app.addInitializer (options) ->
	app.session = new Session

	app.scrollStates = {}

	app.addRegions
		mainRegion: '#main'
		navbarRegion: '#navbar'

	app.navbarView = new NavbarView {model: app.session}
	app.navbarRegion.show app.navbarView

	new PageRouter app
	new UserRouter app
	new RecipeRouter app

	Backbone.history.start()

	$(document).scroll app.saveScrollState.bind app
$ -> app.start()
