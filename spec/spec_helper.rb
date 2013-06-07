require "bacon"
require "mocha-on-bacon"

__LIB_PATH__ = File.join(File.dirname(__FILE__), "..")
$: << __LIB_PATH__

require "pry"
require "necro"


def necro_config
  if Necro.const_defined?(:CONFIG)
    Necro::CONFIG
  else
    Necro.const_set(:CONFIG, mock())
    Necro::CONFIG
  end
end




