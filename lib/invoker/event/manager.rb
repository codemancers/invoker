module Invoker
  module Event
    class Manager
      attr_accessor :scheduled_events, :triggered_events

      def initialize
        @scheduled_events = Hash.new([])
        @triggered_events = []
      end

      def trigger(command_label, event_name = nil)
        triggered_events << OpenStruct.new(:command_label, :event_name => event_name)
      end

      def schedule_event(command_label, event_name = nil, &block)
        scheduled_events[command_label] << OpenStruct.new(:event_name => event_name, :block => block)
      end

      def run_scheduled_events
        triggered_events.each do |triggered_event|
          matched_events = scheduled_events[triggered_event.command_label]
          filtered_matched_events = filter_matched_events(matched_events)
          filtered_matched_events.each {|event| yield event }
        end
      end

      private
      def filter_matched_events(matched_events, event)
        matched_events.select do |matched_event|
          !event.event_name || event.event_name == matched_event.event_name
        end
      end

    end
  end
end
