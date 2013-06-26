require "spec_helper"

describe Invoker::Event::Manager do
  describe "Run scheduled events" do
    before do
      @event_manager = Invoker::Event::Manager.new()
    end

    it "should run matched events" do
      @event_manager.schedule_event("foo", :exit) { 'exit foo' }
      @event_manager.trigger("foo", :exit)

      @event_manager.run_scheduled_events do |event|
        event.block.call.should.equal("exit foo")
      end

      @event_manager.scheduled_events.should.be.empty
      @event_manager.triggered_events.should.be.empty
    end

    it "should remove triggrered and scheduld events on run" do
      @event_manager.schedule_event("foo", :exit) { 'exit foo' }
      @event_manager.schedule_event("bar", :entry) { "entry bar"}
      @event_manager.trigger("foo", :exit)
      @event_manager.trigger("baz", :exit)

      @event_manager.run_scheduled_events do |event|
        event.block.call.should.equal("exit foo")
      end

      @event_manager.scheduled_events.should.not.be.empty
      @event_manager.triggered_events.should.not.be.empty

      baz_containing_event = lambda do |events| 
        events.detect {|event| event.command_label == "baz" }
      end

      bar_containing_scheduled_event = lambda do |events|
        events.keys.detect {|event_key| event_key == "bar" }
      end

      @event_manager.triggered_events.should.be.a baz_containing_event
      @event_manager.scheduled_events.should.be.a bar_containing_scheduled_event
    end

    it "should not run unmatched events" do
      @event_manager.schedule_event("bar", :entry) { "entry bar"}
      @event_manager.trigger("foo", :exit)

      events_ran = false
      @event_manager.run_scheduled_events do |event|
        events_ran = true
      end
      events_ran.should.be.false
    end
  end
end
