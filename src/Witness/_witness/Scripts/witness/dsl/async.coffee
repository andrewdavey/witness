# reference "../Dsl.coffee"

@witness.Dsl::async = (func, timeout) ->
    func.async = { timeout: timeout }
    func
