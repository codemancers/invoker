module Invoker
  module Event
    class Manager
      attr_accessor :scheduled_events, :triggered_events

      def initialize
        @scheduled_events = Hash.new {|h,k| h[k] = [] }
        @triggered_events = []
        @trigger_mutex = Mutex.new()
      end

      # Trigger an event. The event is not triggered immediately, but is just scheduled to be
      # triggered.
      #
      # @param command_label [String] Command for which event should be triggered
      # @param event_name [Symbol, nil] The optional event name
      def trigger(command_label, event_name = nil)
        @trigger_mutex.synchronize do
          triggered_events << OpenStruct.new(
            :command_label => command_label, 
            :event_name => event_name)
        end
      end

      # Schedule an Event. The event will only trigger when a scheduled event matches
      # a triggered event.
      #
      # @param command_label [String] Command for which the event should be triggered
      # @param event_name [String, nil] Optional event name
      # @param block The block to execute when event actually triggers
      def schedule_event(command_label, event_name = nil, &block)
        scheduled_events[command_label] << OpenStruct.new(:event_name => event_name, :block => block)
      end

      # On next iteration of event loop, this method is called and we try to match
      # scheduled events with events that were triggered. 
      def run_scheduled_events
        filtered_events_by_name_and_command = []

        triggered_events.each_with_index do |triggered_event, index|
          matched_events = scheduled_events[triggered_event.command_label]
          if matched_events && !matched_events.empty?
            filtered_events_by_name_and_command, unmatched_events = 
              filter_matched_events(matched_events, triggered_event)
            triggered_events[index] = nil
            remove_scheduled_event(unmatched_events, triggered_event.command_label)
          end
        end
        triggered_events.compact!

        filtered_events_by_name_and_command.each {|event| yield event }
      end

      private
      def filter_matched_events(matched_events, event)
        matched_filtered_events = []
        
        matched_events.each_with_index do |matched_event, index|
          if !event.event_name || event.event_name == matched_event.event_name
            matched_filtered_events << matched_event
            matched_events[index] = nil
          end
        end
        [matched_filtered_events, matched_events.compact]
      end

      def remove_scheduled_event(matched_events, command_label)
        if !matched_events || matched_events.empty?
          scheduled_events.delete(command_label)
        else
          scheduled_events[command_label] = matched_events
        end
      end

    end
  end
end
