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
      end
    end
  end
end
