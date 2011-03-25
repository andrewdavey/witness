Witness.util = {

    parseFunctionName: function Witness_util_parseFunctionName(func) {
        return func.toString()
                   .match(/function\s+(.*)\s*\(/)[1];
    },

    expandCasing: function (text) {
        return text.replace(/([a-z])([A-Z])/g, function (_,a,b) { return a + " " + b.toLowerCase(); });
    }

};