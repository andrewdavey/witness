# reference "../Dsl.coffee"
# reference "async.coffee"
# reference "defineActions.coffee"
# reference "should.coffee"
# reference "../Keys.coffee"

# We want to allow natural, jQuery-style, actions in scenarios. For example:
#   when: [ $("input").val("test"), $("button").click() ]
# Therefore we replace the `$` function with our own. This new function returns an object 
# that mirrors all the functions defined on jQuery.fn.
# These new functions return Witness.Action objects, which when run, perform the original
# jQuery function.

# This class creates the replacement jQuery objects.
# So `$("selector")` maps to `new JQueryActions("selector")`
class JQueryActions
	constructor: (@selector) ->
	
	# This is a class generating helper - not an instance function!
	createJQueryAction = (name, originalFunction) ->
		(args...) ->
			selector = @selector
			func = (args...) ->
				elements = jQuery(selector, @document)
				originalFunction.apply(elements, args)

			new Witness.Action func, args, "#{name} #{selector}"

	# Add functions to this class by iterating over jQuery.fn
	JQueryActions::[name] = createJQueryAction(name, value) for own name, value of jQuery.fn

	# Special case the click action to make it send real browser click events.
	# This means clicking regular <a href> elements will trigger navigation.
	click: -> 
		selector = @selector
		func = ->
			# Thanks to http://stackoverflow.com/questions/1421584/how-can-i-simulate-a-click-to-an-anchor-tag/1421968#1421968
			fakeClick = (anchorObj) =>
				if @document.createEvent
					evt = @document.createEvent "MouseEvents"
					evt.initMouseEvent "click", true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null
					anchorObj.dispatchEvent evt
				else if anchorObj.click
					anchorObj.click()
				else
					throw new Error "Unable to simulate click in this web browser."

			jQuery(selector, @document).each -> fakeClick this
		new Witness.Action func, [], "click #{selector}"

	# Simulate typing characters into an input element
	type: (text) ->
		selector = @selector
		func = ->
			sendTextInputToElement = (element) =>
				if @document.createEvent
					# This code is only webkit-friendly for now
					evt = @document.createEvent "TextEvent"
					evt.initTextEvent "textInput", true, true, null, text
					# Element must have focus to receive the event
					element.focus()
					element.dispatchEvent evt
				else
					jQuery(element).val(text)

			sendKeyToElement = (element) =>
				# The target window's jQuery MUST be used to trigger events.
				# Otherwise they won't actually call the bound handlers.
				# I assume this is because jQuery stores the handlers in its
				# window object. So different jQuery means different window.
				$element = @window.jQuery element
				for name in ["keydown", "keyup"]
					event = @window.jQuery.Event name
					event.which = text
					event.shiftKey = false
					event.altKey = false
					event.ctrlKey = false
					event.metaKey = false
					$element.trigger event
					return false if event.isDefaultPrevented()
				
				return true

			sendTabToElement = (element) =>
				return if not sendKeyToElement element

				focusableElements = jQuery ":focusable", @document
				nextIndex = null
				for focusableElement, i in focusableElements
					if focusableElement == element
						nextIndex = (i + 1) % focusableElements.length
						break
				focusableElements[nextIndex].focus() if nextIndex?

			invoke = if typeof text == "string"
				sendTextInputToElement
			else if text == Witness.Dsl::TAB
				sendTabToElement
			else
				sendKeyToElement

			jQuery(selector, @document).each -> invoke this

		new Witness.Action func, [], "type #{text}"


# Adding $ to the DSL makes it globally available in specification scripts
# and overwrite the existing jQuery function.
this.Witness.Dsl::$ = (selector) -> new JQueryActions(selector)


applySelector = (context,propertyNames) -> jQuery(propertyNames[0],context.document)

this.Witness.Dsl::defineShouldFunctions
	haveText:
		getActual: (context, propertyNames) ->
			applySelector(context, propertyNames).text()
		test: (actual, expected) ->
			actual == expected
		description: (selector, expected) ->
			"#{selector} should have the text \"#{expected}\""
		error: (selector, actual, expected) ->
			"Expected #{selector} to have text \"#{expected}\", but was \"#{actual}\""
	match:
		getActual: (context, propertyNames) ->
			applySelector(context, propertyNames).length
		test: (actual, expected) ->
			actual == expected
		description: (selector, expected) ->
			"The selector #{selector} should match  \"#{expected}\" elements"
		error: (selector, actual, expected) ->
			"Expected #{selector} to have \"#{expected}\" elements, but matched \"#{actual}\" elements"
	haveClass:
		getActual: (context, propertyNames) ->
			applySelector(context, propertyNames)
		test: (actual, expected) ->
			actual.hasClass(expected)
		description: (selector, expected) ->
			"The element matching #{selector} should have a class of \"#{expected}\""
		error: (selector, actual, expected) ->
			"Expected #{selector} to have a class of \"#{expected}\" elements, but has \"#{actual.attr('class')}\""

	haveLength:
		getActual: (context, propertyNames) ->
			applySelector(context, propertyNames).length
		test: (actual, expected) ->
			actual == expected
		description: (selector, expected) ->
			"The selector #{selector} should match #{expected} element" + (if expected != 1 then "s" else "")
		error: (selector, actual, expected) ->
			"The selector \"#{selector}\" matched #{actual} element#{if actual != 1 then "s" else ""} instead of #{expected}"
		
	haveVal: 
		getActual: (context, propertyNames) ->
			applySelector(context, propertyNames).val()
		test: (actual, expected) ->
			actual == expected
		description: (selector, expected) ->
			"The element #{selector} should have the value \"#{expected}\""
		error: (selector, actual, expected) ->
			"Expected the element #{selector} to have the value \"#{expected}\", but was \"#{actual}\""
