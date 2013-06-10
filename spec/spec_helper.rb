require "bacon"
require "mocha-on-bacon"

__LIB_PATH__ = File.join(File.dirname(__FILE__), "..")
$: << __LIB_PATH__

require "pry"
require "invoker"


def invoker_config
  if Invoker.const_defined?(:CONFIG)
    Invoker::CONFIG
  else
    Invoker.const_set(:CONFIG, mock())
    Invoker::CONFIG
  end
end

def invoker_commander
  if Invoker.const_defined?(:COMMANDER)
    Invoker::COMMANDER
  else
    Invoker.const_set(:COMMANDER, mock())
    Invoker::COMMANDER
  end
end


