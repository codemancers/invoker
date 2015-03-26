module Invoker
  class DNSCache
    attr_accessor :dns_data

    # INI:
    # [app]
    # port = 8000
    # location = www2.app/blah
    #
    # [chat]
    # port = 8001
    # location www.app/chat
    #
    # [api]
    # port = 8002
    # location = www.app/api
    #
    # dns_data:
    # {
    #   'api' => [
    #     ['', 8002]
    #   ],
    #   'app' => [
    #     ['', 8000]
    #   ],
    #   'chat' => [
    #     ['', 8001]
    #   ],
    #   'www.app' => [
    #     ['', 8000],
    #     ['/api, 8002],
    #     ['/chat, 8001]
    #   ],
    #   'www2.app' => [
    #     ['/blah', 8000]
    #   ]
    # }
    def initialize(config)
      self.dns_data = Hash.new {|h,k| h[k] = []}
      @dns_mutex = Mutex.new
      Invoker.config.processes.each do |process|
        if process.port
          add(process.label, process.port)
          if process.location
            process.location.split(' ').each do |loc|
              add(loc, process.port)
            end
          end
        end
      end
    end

    def find_process(host, path)
      @dns_mutex.synchronize {
        until dns_data.include?(host) || host.nil?
          host = host.split('.', 2)[1]
        end

        dns_data[host].reverse_each {|prefix, port|
          if path_matches_prefix?(path, prefix)
            return {:port => port}
          end
        }

        nil
      }
    end

    def add(location, port)
      @dns_mutex.synchronize {
        host, path_prefix = split_host_path(location)
        (dns_data[host] << [path_prefix.to_s, port]).sort_by! &:length
      }
    end

    private
    def split_host_path(label)
      label.split(%r{(?=/)}, 2)
    end

    def path_matches_prefix?(path, prefix)
      path.start_with?(prefix) && [nil, "/", "?"].member?(path[prefix.length])
    end
  end
end
