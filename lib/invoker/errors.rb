module Invoker
  module Errors
    class ToomanyOpenConnections < StandardError; end
    class ProcessTerminated < StandardError
      attr_accessor :message, :ready_fd
      def initialize(ready_fd, message)
        @ready_fd = ready_fd
        @message = message
      end
    end

    class NoValidPortFound < StandardError; end
    class InvalidConfig < StandardError; end
  end
end
