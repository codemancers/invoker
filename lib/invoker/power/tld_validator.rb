module Invoker
  module Power
    class TldValidator
      class << self
        def validate(tld)
          unless valid_tld?(tld)
            error_message = 'Top level domain can only contain lower case alphabets. Please rerun setup with a valid top level subdomain.'

            Invoker::Logger.puts(error_message.color(:red))
            exit
          end
        end

        private

        def valid_tld?(tld)
          /^[a-z]+$/ =~ tld
        end
      end
    end

      private
    end

    class Tld
      def self.new(tld_value = nil)
        tld_value.nil? ? DefaultTld.new : CustomTld.new(tld_value)
      end

      def self.default_value
        DefaultTld.value
      end
    end
  end
end
