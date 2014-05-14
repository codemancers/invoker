require "yaml"

module Invoker
  module Power
    # Save and Load Invoker::Power config
    class ConfigExists < StandardError; end

    class Config
      CONFIG_LOCATION = File.join(Dir.home, ".invoker", "config")

      def self.has_config?
        File.exist?(CONFIG_LOCATION)
      end

      def self.create(options = {})
        if has_config?
          raise ConfigExists, "Config file already exists at location #{CONFIG_LOCATION}"
        end
        config = new(options)
        config.save
      end

      def self.delete
        if File.exist?(CONFIG_LOCATION)
          File.delete(CONFIG_LOCATION)
        end
      end

      def initialize(options = {})
        @config = options
      end

      def self.load_config
        config_hash = File.open(CONFIG_LOCATION, "r") { |fl| YAML.load(fl) }
        new(config_hash)
      end

      def dns_port=(dns_port)
        @config[:dns_port] = dns_port
      end

      def http_port=(http_port)
        @config[:http_port] = http_port
      end

      def https_port=(https_port)
        @config[:https_port] = https_port
      end

      def ipfw_rule_number=(ipfw_rule_number)
        @config[:ipfw_rule_number] = ipfw_rule_number
      end

      def dns_port; @config[:dns_port]; end
      def http_port; @config[:http_port]; end
      def ipfw_rule_number; @config[:ipfw_rule_number]; end

      def https_port
        @config[:https_port]
      end

      def save
        File.open(CONFIG_LOCATION, "w") do |fl|
          YAML.dump(@config, fl)
        end
        self
      end
    end
  end
end
