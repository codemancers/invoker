require 'invoker/power/power'

module Invoker
  module Power
    class Setup
      module Common
        def tld
          Invoker::Power.tld
        end

        def tld_value
          Invoker::Power.tld_value
        end
      end
    end
  end
end
