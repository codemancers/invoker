module Invoker
  class DNSCache
    attr_accessor :dns_data

    def initialize(config)
      self.dns_data = {}
      @dns_mutex = Mutex.new
      Invoker.config.processes.each do |process|
        if process.port
          dns_data[process.label] = { 'port' => process.port, 'alias' => make_regex(process.alias) }
        end
      end
    end

    def [](process_name)
      @dns_mutex.synchronize { dns_data[process_name] || alias_lookup(process_name) }
    end

    def add(name, port, ip = nil)
      @dns_mutex.synchronize { dns_data[name] = { 'port' => port, 'ip' => ip } }
    end

    def alias_lookup(process_name)
      dns_data.each do |label, opts|
        if re = opts['alias']
          return opts if re =~ process_name
        end
      end
      nil
    end

    def make_regex(aliases)
      return unless aliases
      aliases = aliases.split(/\s*,\s*/)

      aliases.map! do |path|
        path.gsub!('.', '\.')
        path.gsub!(/\*+/) do |match|
          match == '*' ? '[^.]+' : '.*'
        end
        %r/\A#{path}\z/
      end

      Regexp.union aliases
    end
  end
end
