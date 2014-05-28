module Invoker
  module Power
    module Distro
      class Redhat < Base
        def install_required_software
          system("yum --assumeyes install dnsmasq rinetd")
        end
      end
    end
  end
end
