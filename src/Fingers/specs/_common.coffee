fingersScripts = [
	"lib/jquery.js"
	"lib/arms-common.js"
	"lib/jquery-ui/jquery-ui-1.8.7.custom.min.js"
	"lib/ckeditor/ckeditor.js"
	"lib/ckeditor/adapters/jquery.js"
	"debug/fingers.js"
]

# Helper function to create a basic page with fingers initialized
@createFingersUI = (htmlString) -> [
	html htmlString
	loadScripts fingersScripts
	execute -> fingers.controller() # initializes the fingers system
]
