module Invoker
  class ProcessPrinter
    
    def self.to_json(workers)
      final_json = []
      Invoker::CONFIG.processes.each do |process|
        if worker = workers[process.label]
          final_json << {
            :command => process.cmd, :command_label => process.label, 
            :dir => process.dir, :pid => worker.pid
          }
        else
          final_json << {
            :command => process.cmd, :command_label => process.label, 
            :dir => process.dir
          }
        end
      end

      final_json.to_json
    end

    def self.print_table(json_data)
      final_json = JSON.parse(json_data)
      if final_json && !final_json.empty?
        json_for_printing = []
        final_json.each do |json_row|
          if json_row["pid"]
            json_for_printing << colorize_hash(json_row, "green")
          else
            json_row["pid"] = "[light_black]not running[/]"
            json_for_printing << colorize_hash(json_row, "light_black")
          end
        end
        Formatador.display_compact_table(json_for_printing)
      end
    end

    private
    def self.colorize_hash(hash, color)
      hash.inject({}) do |mem,(key,obj)|
        mem[key] = "[#{color}]#{obj}[/]"
        mem
      end
    end

  end
end
