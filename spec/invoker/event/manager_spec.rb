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
        event.block.call.should == "exit foo"
      end

      @event_manager.scheduled_events.should be_empty
      @event_manager.triggered_events.should be_empty
    end

    it "should remove triggrered and scheduld events on run" do
      @event_manager.schedule_event("foo", :exit) { 'exit foo' }
      @event_manager.schedule_event("bar", :entry) { "entry bar"}
      @event_manager.trigger("foo", :exit)
      @event_manager.trigger("baz", :exit)

      @event_manager.run_scheduled_events do |event|
        event.block.call.should == "exit foo"
      end

      @event_manager.scheduled_events.should_not be_empty
      @event_manager.triggered_events.should_not be_empty

      baz_containing_event = @event_manager.triggered_events.map(&:command_label)
      baz_containing_event.should include("baz")

      bar_containing_scheduled_event = @event_manager.scheduled_events.keys
      bar_containing_scheduled_event.should include("bar")
    end

    it "should handle multiple events for same command" do
      @event_manager.schedule_event("foo", :exit) { 'exit foo' }
      @event_manager.schedule_event("foo", :entry) { "entry bar"}
      @event_manager.trigger("foo", :exit)

      @event_manager.run_scheduled_events { |event| }


      @event_manager.schedule_event("foo", :exit) { 'exit foo' }
      @event_manager.trigger("foo", :exit)

      @event_manager.scheduled_events.should_not be_empty
      @event_manager.triggered_events.should_not be_empty
    end

    it "should not run unmatched events" do
      @event_manager.schedule_event("bar", :entry) { "entry bar"}
      @event_manager.trigger("foo", :exit)

      events_ran = false
      @event_manager.run_scheduled_events do |event|
        events_ran = true
      end
      events_ran.should be_false
    end
  end
end
