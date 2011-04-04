﻿// Add newer functions to Array.prototype that are missing in older browsers.
// (From https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Array)

if (!Array.prototype.every) {
    Array.prototype.every = function (fun /*, thisp */) {
        "use strict";

        if (this === void 0 || this === null)
            throw new TypeError();

        var t = Object(this);
        var len = t.length >>> 0;
        if (typeof fun !== "function")
            throw new TypeError();

        var thisp = arguments[1];
        for (var i = 0; i < len; i++) {
            if (i in t && !fun.call(thisp, t[i], i, t))
                return false;
        }

        return true;
    };
}

if (!Array.prototype.map) {
    Array.prototype.map = function (fun /*, thisp */) {
        "use strict";

        if (this === void 0 || this === null)
            throw new TypeError();

        var t = Object(this);
        var len = t.length >>> 0;
        if (typeof fun !== "function")
            throw new TypeError();

        var res = new Array(len);
        var thisp = arguments[1];
        for (var i = 0; i < len; i++) {
            if (i in t)
                res[i] = fun.call(thisp, t[i], i, t);
        }

        return res;
    };
}

if (!Array.prototype.reduceRight) {
    Array.prototype.reduceRight = function (callbackfn /*, initialValue */) {
        "use strict";

        if (this === void 0 || this === null)
            throw new TypeError();

        var t = Object(this);
        var len = t.length >>> 0;
        if (typeof callbackfn !== "function")
            throw new TypeError();

        // no value to return if no initial value, empty array
        if (len === 0 && arguments.length === 1)
            throw new TypeError();

        var k = len - 1;
        var accumulator;
        if (arguments.length >= 2) {
            accumulator = arguments[1];
        }
        else {
            do {
                if (k in this) {
                    accumulator = this[k--];
                    break;
                }

                // if array contains no values, no initial value to return
                if (--k < 0)
                    throw new TypeError();
            }
            while (true);
        }

        while (k >= 0) {
            if (k in t)
                accumulator = callbackfn.call(undefined, accumulator, t[k], k, t);
            k--;
        }

        return accumulator;
    };
}

if (!Array.prototype.forEach) {
    Array.prototype.forEach = function (fun /*, thisp */) {
        "use strict";

        if (this === void 0 || this === null)
            throw new TypeError();

        var t = Object(this);
        var len = t.length >>> 0;
        if (typeof fun !== "function")
            throw new TypeError();

        var thisp = arguments[1];
        for (var i = 0; i < len; i++) {
            if (i in t)
                fun.call(thisp, t[i], i, t);
        }
    };
}

if (!Array.prototype.filter) {
    Array.prototype.filter = function (fun /*, thisp */) {
        "use strict";

        if (this === void 0 || this === null)
            throw new TypeError();

        var t = Object(this);
        var len = t.length >>> 0;
        if (typeof fun !== "function")
            throw new TypeError();

        var res = [];
        var thisp = arguments[1];
        for (var i = 0; i < len; i++) {
            if (i in t) {
                var val = t[i]; // in case fun mutates this
                if (fun.call(thisp, val, i, t))
                    res.push(val);
            }
        }

        return res;
    };
}