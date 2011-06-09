# reference "Witness.coffee"
# reference "../lib/coffee-script.js"
# reference "../lib/jquery.js"
# reference "../lib/knockout.js"

this.Witness.SimpleRunner = class SimpleRunner
	constructor: (@specsPath) ->
		# Use an observable array, since knockout dislikes binding to a null object.
		# Once loaded, the array will contain the single directory object.
		@directory = ko.observableArray []

	download: ->
		downloading = @downloadSpecificationManifest()
		downloading.then (manifest) => @createSpecificationDirectoryFromManifest manifest
		downloading

	downloadSpecificationManifest: ->
		$.ajax(
			url: "/specs.ashx/" + @specsPath
			cache: false
		)

	createSpecificationDirectoryFromManifest: (manifest) ->
		@directory.push new Witness.SpecificationDirectory manifest	

	downloadSpecification: (url) ->
		waitForSpecifications = $.Deferred()
		$.ajax({
			url: url
			cache: false
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
						try
							functions.done.apply this, doneArgs
						catch e
							
						oldDone.apply this, doneArgs
				if functions.fail?
					oldFail = fail
					fail = (failArgs...) ->
						try
							functions.fail.apply this, failArgs
						catch e
							
						oldFail.apply this, failArgs

				args = [context, done, fail]
				try
					functions.run.apply this, args
				catch e
					
				old.apply this, args

			# return a 'restore' function
			() -> object[name] = old

		
		trace Witness.Specification::, "run", 
			run: ->
				log.write "Testing: " + @description
				log.indent()
			fail: (e) ->
				log.write e
				log.unindent()
			done: ->
				log.unindent()

		trace Witness.Scenario::, "run",
			run: ->
				log.write "Scenario:" + @index
				log.indent()
			done: ->
				log.unindent()
			fail: (e) ->
				log.write e
				log.unindent()

		trace Witness.Assertion::, "run",
			run: -> log.write "Asserting: " + @name
			done: -> log.currentItem.addClass "passed"
			fail: (e) ->
				log.currentItem.addClass "failed"
				log.currentItem.append "<p>#{e}</p>"
		

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
		item = $ "<li>#{message}</li>"
		@currentList.append item
		@currentItem = item

	indent: ->
		@stack.push @currentList
		item = $ "<li/>"
		newList = $ "<ul/>"
		@currentList.append item
		item.append newList
		@currentList = newList

	unindent: ->
		@currentList = @stack.pop()
