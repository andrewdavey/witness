# reference "../Dsl.coffee"
# reference "../Keys.coffee"
# reference "../Action.coffee"
# reference "async.coffee"
# reference "defineActions.coffee"
# reference "should.coffee"

{ Action, Dsl, keyNames } = @Witness

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

			new Action func, args, "#{name} #{selector}"

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
		new Action func, [], "click #{selector}"

	# Simulate typing characters into an input element
	type: (values...) ->
		selector = @selector
		func = ->
			sendTextInputToElement = (element, text) =>
				if @document.createEvent
					# This code is only webkit-friendly for now
					evt = @document.createEvent "TextEvent"
					evt.initTextEvent "textInput", true, true, null, text
					# Element must have focus to receive the event
					element.focus()
					element.dispatchEvent evt
					
					@window.jQuery(element).keydown()
				else
					@window.jQuery(element).val(text)

			sendKeyToElement = (element, keyCode) =>
				# The target window's jQuery MUST be used to trigger events.
				# Otherwise they won't actually call the bound handlers.
				# I assume this is because jQuery stores the handlers in its
				# window object. So different jQuery means different window.
				$element = @window.jQuery element
				for name in ["keydown", "keyup"]
					event = @window.jQuery.Event name
					event.which = keyCode
					event.keyCode = keyCode
					event.shiftKey = false
					event.altKey = false
					event.ctrlKey = false
					event.metaKey = false
					$element.trigger event
					return false if event.isDefaultPrevented()
				
				return true

			sendTabToElement = (element, keyCode) =>
				return unless sendKeyToElement element, keyCode

				focusableElements = jQuery ":focusable", @document
				nextIndex = null
				for focusableElement, i in focusableElements
					if focusableElement == element
						nextIndex = (i + 1) % focusableElements.length
						break
				focusableElements[nextIndex].focus() if nextIndex?

			elements = @window.jQuery selector, @document
			for value in values
				invoke = if typeof value == "string"
					sendTextInputToElement
				else if value == Dsl::TAB
					sendTabToElement
				else
					sendKeyToElement

				elements.each -> invoke this, value

		valueDescriptions = for value in values
			if typeof value == "string"
				"'#{value}'"
			else
				keyNames[value] or ("key:" + value.toString())
		actionDescription = "type #{valueDescriptions.join(', ')} into #{selector}"
		new Action func, [], actionDescription 


	selectCharacters: (start, end) ->
		selector = @selector
		func = ->
			field = jQuery(selector, @document)[0]
			if field.createTextRange
				selRange = field.createTextRange()
				selRange.collapse true
				selRange.moveStart 'character', start
				selRange.moveEnd 'character', end
				selRange.select()
			else if field.setSelectionRange
				field.setSelectionRange start, end
			else if field.selectionStart
				field.selectionStart = start
				field.selectionEnd = end
			field.focus()
		new Action func, [], "Select characters #{start} to #{end}"

# Adding $ to the DSL makes it globally available in specification scripts
# and overwrite the existing jQuery function.
Dsl::$ = (selector) -> new JQueryActions(selector)

# jQuery predicates all have the same getActual function.
# It simply gets the jQuery object for the given selector.
jQueryPredicates = (builders) ->
	for own name, builder of builders
		builder.getActual = (propertyNames) ->
			jQuery propertyNames[0], this.document
	builders

Dsl::extendShould jQueryPredicates
	haveText:
		test: (actual, expected) ->
			actual.text() == expected
		description: (selector, expected) ->
			"#{selector} should have the text \"#{expected}\""
		error: (selector, actual, expected) ->
			"Expected #{selector} to have text \"#{expected}\", but was \"#{actual.text()}\""

	match:
		test: (actual, expected) ->
			actual.length == expected
		description: (selector, expected) ->
			"The selector #{selector} should match  \"#{expected}\" elements"
		error: (selector, actual, expected) ->
			"Expected #{selector} to have \"#{expected}\" elements, but matched \"#{actual.length}\" elements"

	haveClass:
		test: (actual, expected) ->
			actual.hasClass(expected)
		description: (selector, expected) ->
			"The element matching #{selector} should have a class of \"#{expected}\""
		error: (selector, actual, expected) ->
			"Expected #{selector} to have a class of \"#{expected}\" elements, but has \"#{actual.attr('class')}\""

	haveLength:
		test: (actual, expected) ->
			actual.length == expected
		description: (selector, expected) ->
			"The selector #{selector} should match #{expected} element" + (if expected != 1 then "s" else "")
		error: (selector, actual, expected) ->
			"The selector \"#{selector}\" matched #{actual.length} element#{if actual != 1 then "s" else ""} instead of #{expected}"
		
	haveVal: 
		test: (actual, expected) ->
			if jQuery.isArray expected
				actualArray = actual.val()
				for expectedItem, index in expected
					return false if actualArray[index] != expectedItem
				return true
			else
				actual.val() == expected
		description: (selector, expected) ->
			"The element #{selector} should have the value \"#{expected}\""
		error: (selector, actual, expected) ->
			"Expected the element #{selector} to have the value \"#{expected}\", but was \"#{actual.val()}\""

	beActive:
		test: (actual) ->
			actual.length > 0 and actual[0] == @document.activeElement
		description: (selector) ->
			selector + " should be active"
		error: (selector) ->
			"#{selector} was not active"
