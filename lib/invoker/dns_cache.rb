module Invoker
  class DNSCache
    attr_accessor :dns_data

    # INI:
    # [www.app]
    # port = 8000
    #
    # [www.app/chat]
    # port = 8001
    #
    # [app]
    # port = 8002
    #
    # [app/api]
    # port = 8003
    #
    # dns_data:
    # {
    #   'www.app' => [
    #     ['/', 8000],
    #     ['/chat', 8001]
    #   ],
    #   'app' => [
    #     ['/', 8002],
    #     ['/api, 8003]
    #   ]
    # }
    def initialize(config)
      self.dns_data = Hash.new {|h,k| h[k] = []}
      @dns_mutex = Mutex.new
      Invoker.config.processes.each do |process|
        if process.port
          add(process.label, process.port)
        end
      end
    end

    def find_process(host, path)
      @dns_mutex.synchronize {
        until dns_data.include?(host) || host.nil?
          host = host.split('.', 2)[1]
        end

        dns_data[host].reverse_each {|prefix, label, port|
          if path_matches_prefix?(path, prefix)
            return {:process_name => label, :port => port}
          end
        }

        nil
      }
    end

    def add(name, port)
      @dns_mutex.synchronize {
        host, path_prefix = split_host_path(name)
        (dns_data[host] << [path_prefix.to_s, name, port]).sort!
      }
    end

    private
    def split_host_path(label)
      label.split(%r{(?=/)}, 2)
    end

    def path_matches_prefix?(path, prefix)
      path == prefix || path.start_with?(prefix + '/')
    end
  end
end
