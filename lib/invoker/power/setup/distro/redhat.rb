module Invoker
  module Power
    module Distro
      class Redhat < Base
        def install_required_software
          system("yum --assume-yes install dnsmasq rinetd")
        end
      end
    end
  end
end
