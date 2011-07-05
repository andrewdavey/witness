# reference "../Dsl.coffee"

@Witness.Dsl::async = (func, timeout) ->
    func.async = { timeout: timeout }
    func
