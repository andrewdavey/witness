Witness.util = {

    parseFunctionName: function Witness_util_parseFunctionName(func) {
        return func.toString()
                   .match(/function\s+(.*)\s*\(/)[1];
    },

    expandCasing: function (text) {
        return text.replace(/([a-z])([A-Z])/g, function (_, a, b) { return a + " " + b.toLowerCase(); });
    },

    createStepDescription: function (func, args) {
        var funcName = this.parseFunctionName(func);
        if (funcName) {
            var description = this.expandCasing(funcName);
            if (args && args.length) {
                description += " (" + args.map(JSON.stringify).join(", ") + ")";
            }
            return description;
        } else {
            return "<un-named>";
        }
    }

};