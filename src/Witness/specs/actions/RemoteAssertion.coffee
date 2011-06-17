# reference "../witness/dsl/describe.coffee"
# reference "../witness/Assertion.coffee"

describe "Assert expressions on server",
"Given we have server functions": ->
"Then we can assert them":[
  remote(-> serverfunctionthatreturns42() == 42),
  remote(-> serverfunctionthatreturns43() == 43)
]