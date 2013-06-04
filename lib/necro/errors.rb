module Necro
  module Errors
    class ToomanyOpenConnections < StandardError; end
    class ProcessTerminated < StandardError
      def initialize(ready_fd, message)
        @message = message
      end
    end
  end
end
