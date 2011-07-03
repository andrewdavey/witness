# reference "Witness.coffee"
# reference "Sequence.coffee"
# reference "TryAll.coffee"

createDescriptionFromFunction = (func) ->
	return "" if typeof func != "function"
	s = func.toString()
	match = s.match /function\s*\(\)\s*{\s*(.*)\s*}/
	return match[1] if match
	return s

this.Witness.Scenario = class Scenario
	
	constructor: (@parts) ->
		@on = Witness.Event.define "running", "passed", "failed"
		{@given, @when, @then, @dispose} = @parts
		for name in ["given","when","then","dispose"]
			part = @[name]
			if part?
				part.description = part.description.split(' ').slice(1).join(' ')
			else
				@[name] = { description: "", actions: [] }
			
	
		tryAllAssertions = new Witness.TryAll @then.actions
		sequence = new Witness.Sequence [].concat @given.actions, @when.actions, tryAllAssertions
		# The disposes must *always* run, even if the previous sequence fails.
		# So combine them using a TryAll.
		if @dispose.actions.length > 0
			@aggregateAction = new Witness.TryAll [].concat sequence, @dispose.actions
		else
			@aggregateAction = sequence

	run: (outerContext, done, fail) ->
		# We want the context for the scenario run to inherit
		# anything defined in the outer context. This means the 
		# OuterScenario object can set up things to be used by inner
		# scenarios.
		Context = (->)
		Context.prototype = outerContext
		context = new Context()
		# Add some other useful stuff...
		context.scenario = this

		Witness.messageBus.send "ScenarioRunning", this
		@on.running.raise()
		@aggregateAction.run context,
			=>
				@on.passed.raise()
				Witness.messageBus.send "ScenarioPassed", this
				done()
			(error) =>
				@on.failed.raise(error)
				Witness.messageBus.send "ScenarioFailed", this
				fail(error)

	getIFrame: ->
		@iframe or @createAndCacheIFrame()

	setIFrameLoadCallback: (callback, callIfJustLoaded = no) ->
		if @iframeJustLoaded and callIfJustLoaded
			# Sometimes we need a callback to run just after the
			# iframe has loaded e.g. awaitPageLoad()
			@iframeJustLoaded = no
			callback @iframe[0].contentWindow
		else
			@iframeLoadCallback = callback

	createAndCacheIFrame: ->
		@iframe = $ "<iframe/>"
		Witness.messageBus.send "AppendIframe", @iframe
		@iframe.focus()
		@iframe.bind "load", => @handleIFrameLoad()
		@iframe

	handleIFrameLoad: ->
		if @iframeLoadCallback?
			@iframeJustLoaded = no
			
			# Callbacks are single use.
			# So we must clear the current callback property before calling it.
			# Otherwise a new callback could be assigned which would then be cleared!
			callback = @iframeLoadCallback
			@iframeLoadCallback = null 

			callback @iframe[0].contentWindow
		else
			# Remember that the iframe has just loaded so that when there is a callback set
			# we can call it immediately.
			@iframeJustLoaded = yes

	forceReloadIFrame: ->
		@iframe[0].contentWindow.document.location.reload true # force reload

