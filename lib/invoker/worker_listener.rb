module Invoker
  class WorkerListener
    attr_accessor :listeners

    def initialize
      @listeners = {}
    end

    def add(socket, process_name)
      listeners[process_name] ||= []
      listeners[process_name] << socket
    end
  end
end
