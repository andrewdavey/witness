# reference "Witness.coffee"
# reference "Event.coffee"
# reference "Sequence.coffee"
# reference "TryAll.coffee"
# reference "MessageBus.coffee"

{ Event, TryAll, Sequence, messageBus } = @Witness

createDescriptionFromFunction = (func) ->
	return "" if typeof func != "function"
	s = func.toString()
	match = s.match /function\s*\(\)\s*{\s*(.*)\s*}/
	return match[1] if match
	return s

nextUniqueId = 0

@Witness.Scenario = class Scenario
	
	constructor: (@parts) ->
		@uniqueId = "scenario-" + (nextUniqueId++).toString()
		@on = Event.define "running", "passed", "failed"
		{@given, @when, @then, @dispose} = @parts
		for name in ["given","when","then","dispose"]
			part = @[name]
			if part?
				part.description = part.description.split(' ').slice(1).join(' ')
			else
				@[name] = { description: "", actions: [] }
			
	
		tryAllAssertions = new TryAll @then.actions
		sequence = new Sequence [].concat @given.actions, @when.actions, tryAllAssertions
		# The disposes must *always* run, even if the previous sequence fails.
		# So combine them using a TryAll.
		if @dispose.actions.length > 0
			@aggregateAction = new TryAll [].concat sequence, @dispose.actions
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

		messageBus.send "ScenarioRunning", this
		@on.running.raise()
		@aggregateAction.run context,
			=>
				messageBus.send "ScenarioPassed", this
				@on.passed.raise()
				done()
			(error) =>
				messageBus.send "ScenarioFailed", this, error
				@on.failed.raise(error)
				fail(error)

	getIFrame: ->
		@iframe or @createAndCacheIFrame()

	getNewIFrame: ->
		@iframe.remove() if @iframe?
		@createAndCacheIFrame()

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
		messageBus.send "AppendIframe", @iframe, @uniqueId
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

