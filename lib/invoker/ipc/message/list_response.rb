module Invoker
  module IPC
    module Message
      class ListResponse < Base
        include Serialization
        message_attributes :processes
        def initialize(options)
          self.processes = []
          process_array = options[:processes] || options['processes']
          process_array.each do |process_hash|
            processes << Process.new(process_hash)
          end
        end

        def self.from_workers(workers)
          process_array = []
          Invoker.config.processes.each do |process|
            worker_attrs = {
              shell_command: process.cmd,
              process_name: process.label,
              dir: process.dir,
              port: process.port
            }
            if worker = workers[process.label]
              worker_attrs.update(pid: worker.pid)
            end
            process_array << worker_attrs
          end

          new(processes: process_array)
        end
      end
    end
  end
end
