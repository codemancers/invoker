module Invoker
  class ProcessPrinter
    MAX_COLUMN_WIDTH = 40

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
        if obj.to_s.length > MAX_COLUMN_WIDTH
          short_command = "#{obj.to_s[0..MAX_COLUMN_WIDTH]}.."
          mem[key] = "[#{color}]#{short_command}[/]"
        else
          mem[key] = "[#{color}]#{obj}[/]"
        end
        mem
      end
    end

  end
end
