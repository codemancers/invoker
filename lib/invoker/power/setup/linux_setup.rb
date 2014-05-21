module Invoker
  module Power
    class LinuxSetup
      def tld_setup
        tld_string =<<-EOD
local=/dev/
address=/dev/127.0.0.1
        EOD
        tld_string
      end

      def rinetd_setup
        rinetd_string =<<-EOD
0.0.0.0 80 0.0.0.0 23400
0.0.0.0 443 0.0.0.0 23401
        EOD
        rinetd_string
      end
    end
  end
end
