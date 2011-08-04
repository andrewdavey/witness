describe "Assert expressions on server",
{
	"Given we have server functions": ->
	"Then we can assert them": [
		remote(-> utils.serverfunctionthatreturns42() == 42),
		remote(-> utils.serverfunctionthatreturns43() == 43)
	]
}
