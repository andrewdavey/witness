/*
	controller.js
*/

	fingers.util.controller = base.createChild();

	fingers.util.controller.addInstanceMethods({
		
			init : function(){
			
				var that = this;
				var formElements = $( '.' + fingersConfig.controller.selector );

				this.editViews = [];
				this.staticViews = [];

				this.length = formElements.length;

				formElements.each( function(){
					
					that.invokeView( $(this) );

				});

				return this;
			}, 

			invokeView : function( jq ){
				
					// pull out the edit view type using a bit of magic regex

					var i, matches, view, viewType = '', uid, words;

					// find the view type... view-*

					// because this information is in the class attribute of the form element, we pull out all the classes
					// and find one that begins view-
					var classes = (jq.attr('class')).split(' ');

					classes.forEach(function( element ){
						
						matches = element.match(/^view\-([A-Za-z0-9\-]+)$/);

						if(matches){
							
							view = matches[1];

						}
					
					});

					//format the viewtype into camelCase, the convention for middleware class names.
					viewType = view.replace(/\-/g, ' ').toCamelCase().replace(/\s/g, '');

					// now that we have it, push a new instance of editView into the editViews array.
					// We invoke editView by passing it a string of teh viewType and a databox.


					uid = fingers.formData.registerField( jq );

					this.registerEditView( fingers.editView( viewType, uid ) );

					// hide the form element
					jq.hide();

					return this;

			},

			registerEditView : function( view ){
				
				this.editViews.push( view );

				return this;


			}


	});

	fingers.controller = fingers.util.controller;
