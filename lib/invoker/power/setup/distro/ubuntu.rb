require "invoker/power/setup/distro/debian"

module Invoker
  module Power
    module Distro
      class Ubuntu < Debian
        def restart_services
          system('service dnsmasq restart')
        end
      end
    end
  end
end
