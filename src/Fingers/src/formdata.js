/*

	form-data.js

*/

	fingers.util.addStaticMethods({
		
		formData : base.createChild()

	});

	fingers.util.formData.addStaticMethods({
		
		uid : 0

	});

	fingers.util.formData.addInstanceMethods({
		
		init : function(){
			
			this.fields = {};

		},

		registerField : function( element ){

			var newElement, storedValue;

			if(element){

				// wrap with jQuery object if it's not already happened.
				element.selector ? newElement = element : newElement = $(element);
				storedValue = newElement.val();

			}else{
				
				// throw an error
				throw('Invalid DOM element ');

			}
			
			this.fields[ ++fingers.util.formData.uid ] = {
				
					element : newElement,
					storedValue : storedValue

			};

			return fingers.util.formData.uid;

		},

		value : function( uid, val ){
			
			if(typeof uid==='number' && this.fields[uid]){

				if(arguments.length > 1){
					// update the stored value
					this.fields[uid].storedValue = val;

					// actually update the element
					this.fields[uid].element.val( val );

					// publish a message to say that the field value has been changed
					fingers.broker.publish('event field value changed', fingers.util.message( uid, val ) );

				}else {
					
					return this.fields[uid].storedValue;

				}

			}else{
				
				return false;

			}

		},

		element : function( uid ){
			
			if(uid && typeof uid==='number' && this.fields[uid] && this.fields[uid].element){
				
				return this.fields[uid].element;

			}else{
				
				return false;

			}

		}

	});

	fingers.formData = fingers.util.formData();