// Runs an array of steps in order.
// If any step fails then the sequence fails and stops running.
Witness.Steps.Sequence = (function () {

    function Witness_Sequence(steps) {
        this.steps = steps;
    };

    Witness_Sequence.prototype.run = function Witness_Sequence_run(context, done, fail) {
        /*  Take the step array: [a,b,c]
            And build this nested function:
            function() {
                a.run(
                    context, 
                    function() { 
                        b.run(
                            context, 
                            function() { 
                                c.run(context, done, fail);
                            },
                            fail
                        );
                    },
                    fail
                );
            }
            Yes my brain hurts too!
        */
        var runSequence = this.steps.reduceRight(
            function (next, step) {
                return function () {
                    step.run(context, next, fail);
                }
            },
            done
        );
        runSequence();
    }

    Witness_Sequence.prototype.reset = function Witness_Sequence_reset() {
        this.steps.forEach(function(step) { step.reset(); });
    }

    return Witness_Sequence;

})();