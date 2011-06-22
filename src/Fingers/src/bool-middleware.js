/*
	bool-middleware.js
*/

(function(fingers){

	fingers.middleware.addStaticMethods({
		
		bool : fingers.middleware.createChild('bool-middleware')

	});

	fingers.middleware.bool.addInstanceMethods({

		createEditView : function(){
			
			this.editView = $('<input type="checkbox" class="edit-view-control bool" />');

		},

		persistChange : function( ){
					
				// get the current value from the input field
				// pass to okay

				var isChecked = (this.editView.is(':checked')).toString();

				this.okay(isChecked);

		},

		beginEdit: function(){
			
			// do something

			var that = this;

			if(fingers.formData.element(this.uid)){
				
				this.showEditView();
				this.hideStaticView();


				fingers.formData.value( this.uid ) === 'true' ? this.editView.attr('checked', 'checked') : this.editView.removeAttr('checked');

				//this.element.val(fingers.formData.value( this.uid ));

				this.editView
					.bind('blur', function(){
						that.blurTimeout = setTimeout(function(){
							that.persistChange();
							}, 250);
					})
					.bind('change', function(){
						if(that.blurTimeout!== -1){
							
							clearTimeout(that.blurTimeout);
							that.blurTimeout = -1;

						}
						$(this).focus();

					})
					.bind('keydown', function( e ) {
						if (e.which === 13) {
							that.persistChange( this );
						}
						if (e.which === 27){
							that.cancel();							
						}
					});				
				
				this.editView.focus();
				
			}


		}

	});

})(fingers);