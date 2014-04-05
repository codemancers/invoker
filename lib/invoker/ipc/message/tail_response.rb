module Invoker
  module IPC
    module Message
      class TailResponse < Base
        include Serialization
        message_attributes :tail_line
      end
    end
  end
end
