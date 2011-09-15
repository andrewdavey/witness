# reference "../Dsl.coffee"
# reference "async.coffee"
# reference "defineActions.coffee"
# reference "ajax_request.coffee"

{ async, defineActions, ajax_request } = @witness.Dsl::

defineActions
	loadResource:  async (options) ->
		ajax_request options, this