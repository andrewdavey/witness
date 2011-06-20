# reference "../Dsl.coffee"
# reference "defineActions.coffee"
# reference "should.coffee"

describe "jQuery match",
{
 "Given we match a  match against a document with one matching element":->
    @document = $("<div><div id='match'>bob</bob></div>")
   "Then it matches": "#match" : should.match 1
},
{
 "Given we match a match against a document with no matching elements":->
    @document = $("<div><div id='match'>bob</bob></div>")
   "Then it matches": "#notmatch" : shouldnot.match 1
}