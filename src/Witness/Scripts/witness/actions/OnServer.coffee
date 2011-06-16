# reference "../Dsl.coffee"
# reference "../dsl/async.coffee"
# reference "../dsl/defineActions.coffee"

async = @Witness.Dsl::async

@Witness.Dsl::defineActions
    on_server: async (remotefunc) ->
      $.post "/executeonserver.ashx","(#{remotefunc})(this)", (data) => 
        @done(data)
      ,'json'