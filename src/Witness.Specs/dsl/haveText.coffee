# reference "../Dsl.coffee"
# reference "defineActions.coffee"
# reference "should.coffee"

describe "jQuery haveText",
{
	"Given we are matching text with a matching selector": ->
		@document = jQuery("<div><div id='match'>bob</bob></div>")

	"Then it matches":
		"#match" : should.haveText "bob"
},
{
	"Given we are matching text with a non matching selector": ->
		@document = jQuery("<div><div id='notmatch'>bob</bob></div>")

	"Then it does not":
		"#match" : shouldnot.haveText "bob"
}
