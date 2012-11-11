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
		model = new Recipe
			_id: id
		model.fetch()

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
