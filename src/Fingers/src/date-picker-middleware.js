/*
	middleware.js
*/

(function(fingers){

	fingers.middleware.addStaticMethods({
		
		datePicker : fingers.middleware.createChild('middleware')

	});

	fingers.middleware.datePicker.addInstanceMethods({

		createEditView : function(){
			
			this.editView = $('<input type="text" class="edit-view-control date-picker" />');

			return this;

		},

		beginEdit: function(){
			
			// do something
			var that = this;

			if(fingers.formData.element(this.uid)){

				this.hideStaticView();

				fingers.formData.element(this.uid).after(this.editView);

				this.editView.datepicker({ 
					onSelect : function(){
						that.persistChange();		
					}, 
					onClose : function(){
						that.cancel();	

					},
					changeYear: "true", 
					dateFormat: 'dd M yy'
				}).focus();

			}

			return this;
		
		},

		endEdit : function(){

			this.editView.datepicker('destroy');

			this.hideEditView();

			this.showStaticView();
			// do somethign else

			return this;

		}


	});

})(fingers);