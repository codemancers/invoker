module Invoker
  class DNSCache
    attr_accessor :dns_data

    def initialize(config)
      self.dns_data = {}

      config.processes.each do |process|
        if process.port
          dns_data[process.label] = {
            'port' => process.port
          }
        end
      end
    end

    def [](process_name)
      dns_data[process_name]
    end

    def add(name, port)
      dns_data[name] = {
        'port' => port
      }
    end
  end
end
