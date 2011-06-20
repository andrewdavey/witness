# reference "../Dsl.coffee"
# reference "defineActions.coffee"
# reference "should.coffee"

describe "jQuery haveText",
{
  "Given we are matching text with a matching selector":->
    @document = $("<div><div id='match'>bob</bob></div>")
  "Then it matches": "#match" : should.haveText "bob"
},
{
  "Given we are matching text with a non matching selector":->
    @document = $("<div><div id='notmatch'>bob</bob></div>")
   "Then it does not": "#match" : shouldnot.haveText "bob"
}

describe "jQuery haveElements",
{
 "When the we match a default have elements with one matching element":->
    @document = $("<div><div id='match'>bob</bob></div>")
   "Then it matches": "#match" : should.haveElements 
},
{
 "When the we match a default have elements with no matching element":->
    @document = $("<div><div id='match'>bob</bob></div>")
   "Then it does not match": "#match" : shouldnot.haveElements 
},
{
 "When the we match a default have elements with more than one matching element":->
    @document = $("<div><div id='match'>bob</bob><div id='match'>bob</bob></div>")
   "Then it does not match": "#match" : shouldnot.haveElements 
},
{
 "Given we match a specified number of elements that are in the dom":->
   @document = $("<div><div id='match'>bob</bob><div id='match'>bob</bob></div>")
  "Then it matches":"#match" : should.haveElements 2
}
