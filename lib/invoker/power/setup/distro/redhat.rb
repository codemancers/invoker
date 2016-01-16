module Invoker
  module Power
    module Distro
      class Redhat < Base
        def install_required_software
          system("yum --assumeyes install dnsmasq socat")
        end
      end
    end
  end
end
