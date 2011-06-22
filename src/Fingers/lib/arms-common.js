var arms = {};

(function ($){

   arms.displayStumpyHeader = function () {
        var headerDiv = $('#header');
        if( headerDiv.length > 0 ) {
            headerDiv.attr('id', 'stumpyHeader' );
        }
   }

   arms.displayNormalHeader = function () { 
        var headerDiv = $('#stumpyHeader');
        if( headerDiv.length > 0 ) {
            headerDiv.attr('id', 'header' );
        }
   }

   arms.cleanSearchText = function (txt) {
        return txt.replace(" ", "%20").replace("&", "&amp;");
    }

   //$.datepicker.setDefaults({ changeYear: "true", dateFormat: 'dd M yy' });

})(jQuery);