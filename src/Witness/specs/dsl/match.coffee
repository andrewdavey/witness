# reference "../Dsl.coffee"
# reference "defineActions.coffee"
# reference "should.coffee"

describe "jQuery match",
{
 "Given we match against a document with one matching element":->
    @document = $("<div><div id='match'>bob</bob></div>")
   "Then it matches": "#match" : should.match 1
},
{
 "Given we match against a document with no matching elements":->
    @document = $("<div><div id='match'>bob</bob></div>")
   "Then it matches": "#notmatch" : shouldnot.match 1
}

describe "jQuery has class",
{
 "Given we match an element with the expected class":->
    @document = $("<div><div id='match' class='matched'>bob</bob></div>")
   "Then it matches": "#match" : should.haveClass "matched"
},
{
 "Given we match an element without the specified class":->
    @document = $("<div><div id='match'>bob</bob></div>")
   "Then it does not match": "#match" : shouldnot.haveClass "matched"
},
{
 "Given we do not match any element":->
    @document = $("<div><div id='match'>bob</bob></div>")
   "Then it does not match": "#notmatch" : shouldnot.haveClass "matched"
}
