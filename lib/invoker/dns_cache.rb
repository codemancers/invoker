module Invoker
  class DNSCache
    attr_accessor :dns_data

    def initialize(config)
      self.dns_data = {}
      @dns_mutex = Mutex.new
      Invoker.config.processes.each do |process|
        if process.port
          dns_data[process.label] = { 'port' => process.port }
        end
      end
    end

    def [](process_name)
      @dns_mutex.synchronize { dns_data[process_name] }
    end

    def add(name, port, ip = nil)
      @dns_mutex.synchronize { dns_data[name] = { 'port' => port, 'ip' => ip } }
    end
  end
end
