# reference "../Dsl.coffee"

this.Witness.Dsl::async = (func, timeout) ->
    func.async = { timeout: timeout }
    func