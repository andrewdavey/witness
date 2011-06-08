# reference "Witness.coffee"
# reference "../lib/coffee-script.js"
# reference "../lib/jquery.js"

this.Witness.SimpleRunner = class SimpleRunner
	constructor: () ->
		@specifications = []

	download: (url) ->
		waitForSpecifications = $.Deferred()
		$.ajax({
			url: url
			dataType: 'text'
			success: (script) =>
				if url.match(/.coffee$/)
					script = CoffeeScript.compile(script)
				@executeSpecificationScript script, (specs) =>
					@specifications = @specifications.concat specs
					waitForSpecifications.resolve()
		});
		waitForSpecifications

	executeSpecificationScript: (script, gotSpecifications) ->
		iframe = $("<iframe src='/empty.htm'/>").hide().appendTo("body")
		iframe.load () =>
			iframeWindow = iframe[0].contentWindow
			iframeDoc = iframeWindow.document
			
			# Copy all our scripts into the iframe.
			$("head > script[src]").each(() ->
				iframeDoc.write "<script type='text/javascript' src='#{this.src}'></script>"
			)
			
			# Add a function to the iframe window that will be called when the script has finished running.
			iframeWindow._witnessScriptCompleted = ->
				gotSpecifications dsl.specifications
				# Can't instantly remove the iframe since it's still running this code!
				# So delay for a moment to let the current code finish
				setTimeout (-> iframe.remove()), 200

			dsl = new Witness.Dsl iframeWindow
			dsl.activate()
			iframeDoc.write "<script type='text/javascript'>#{script}</script>"
			iframeDoc.write "<script type='text/javascript'>_witnessScriptCompleted()</script>"
			

	runAll: (log) ->
		trace = (object, name, functions) ->
			old = object[name]
			# replace the function
			object[name] = (context, done, fail) ->
				if functions.done?
					oldDone = done
					done = (doneArgs...) ->
						functions.done.apply this, doneArgs
						oldDone.apply this, doneArgs
				if functions.fail?
					oldFail = fail
					fail = (failArgs...) ->
						functions.fail.apply this, failArgs
						oldFail.apply this, failArgs

				args = [context, done, fail]
				functions.run.apply this, args
				old.apply this, args

			# return a 'restore' function
			() -> object[name] = old

		trace Witness.Specification::, "run", 
			run: ->
				log.write "Testing: " + @description
				log.indent()
			done: -> log.unindent()
			fail: -> log.unindent()

		trace Witness.Scenario::, "run",
			run: ->
				log.write "Scenario:"
				log.indent()
			done: -> log.unindent()
			fail: -> log.unindent()

		trace Witness.Assertion::, "run",
			run: -> log.write "Asserting: " + @name

		@specifications.sort (a,b) ->
			return -1 if a.description < b.description
			return 1  if a.description > b.description
			0

		all = new Witness.TryAll @specifications
		all.run {}, (->), (->)

this.Witness.SimpleRunner.Log = class Log
	constructor: (listElement) ->
		@currentList = listElement
		@stack = []

	write: (message) ->
		@currentList.append "<li>#{message}</li>"

	indent: ->
		@stack.push @currentList
		item = $ "<li/>"
		newList = $ "<ul/>"
		@currentList.append item
		item.append newList
		@currentList = newList

	unindent: ->
		@currentList = @stack.pop()