describe "Event",
{
	"given an Event with a handler added": ->
		@event = new Witness.Event()
		@event.addHandler ((args...) => @handlerCalled = true; @args = args)
	
	inner: [
		{
			"when it is raised": ->
				@event.raise()

			then:
				handlerCalled: should.be true
		},
		{
			"when it is raised with an argument": ->
				@event.raise "arg"

			then:
				args: [ should.be "arg" ]
		}
	]
},
{
	"when Event.define is called with event names": ->
		@events = Witness.Event.define.call null, "started", "finished"
	
	"then Event objects are created":
		events:
			started: should.beInstanceof Witness.Event
			finished: should.beInstanceof Witness.Event
}
