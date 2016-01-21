module Invoker
  module Power
    class DefaultTld
      def custom?
        false
      end

      def value
        default_value
      end

      def validate
      end

      private

      def default_value
        'dev'
      end
    end

    class CustomTld
      def initialize(tld_value)
        @tld_value = tld_value
      end

      def custom?
        true
      end

      def value
        @tld_value
      end

      def validate
        unless valid_tld_value?
          error_message = 'Top level domain can only contain lower case alphabets. Please rerun setup with a valid top level subdomain.'

          Invoker::Logger.puts(error_message.color(:red))
          exit
        end
      end

      private

      def valid_tld_value?
        /^[a-z]+$/ =~ @tld_value
      end
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
