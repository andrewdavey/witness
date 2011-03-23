Witness.util = {

    parseFunctionName: function Witness_util_parseFunctionName(func) {
        return func.toString()
                   .match(/function\s+(.*)\s*\(/)[1];
    }

};