Witness.dsl = {

    initializers: [],
    target: window, // This can be changed by Witness's own tests, not wanting to pollute window.

    addInitializer: function (initializer) {
        this.initializers.push(initializer);
    },

    initialize: function (target) {
        this.initializers.forEach(function (initializer) {
            initializer(target);
        });
    }

};