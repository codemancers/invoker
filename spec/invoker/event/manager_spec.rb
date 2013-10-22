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
        expect(event.block.call).to eq("exit foo")
      end

      expect(@event_manager.scheduled_events).to be_empty
      expect(@event_manager.triggered_events).to be_empty
    end

    it "should remove triggrered and scheduld events on run" do
      @event_manager.schedule_event("foo", :exit) { 'exit foo' }
      @event_manager.schedule_event("bar", :entry) { "entry bar"}
      @event_manager.trigger("foo", :exit)
      @event_manager.trigger("baz", :exit)

      @event_manager.run_scheduled_events do |event|
        expect(event.block.call).to eq("exit foo")
      end

      expect(@event_manager.scheduled_events).not_to be_empty
      expect(@event_manager.triggered_events).not_to be_empty

      baz_containing_event = @event_manager.triggered_events.map(&:command_label)
      expect(baz_containing_event).to include("baz")

      bar_containing_scheduled_event = @event_manager.scheduled_events.keys
      expect(bar_containing_scheduled_event).to include("bar")
    end

    it "should handle multiple events for same command" do
      @event_manager.schedule_event("foo", :exit) { 'exit foo' }
      @event_manager.schedule_event("foo", :entry) { "entry bar"}
      @event_manager.trigger("foo", :exit)

      @event_manager.run_scheduled_events { |event| }


      @event_manager.schedule_event("foo", :exit) { 'exit foo' }
      @event_manager.trigger("foo", :exit)

      expect(@event_manager.scheduled_events).not_to be_empty
      expect(@event_manager.triggered_events).not_to be_empty
    end

    it "should not run unmatched events" do
      @event_manager.schedule_event("bar", :entry) { "entry bar"}
      @event_manager.trigger("foo", :exit)

      events_ran = false
      @event_manager.run_scheduled_events do |event|
        events_ran = true
      end
      expect(events_ran).to be_false
    end
  end
end
