module Invoker
  module Power
    class UrlRewriter
      DEFAULT_PROCESS_NAME = "default"

      def select_backend_config(complete_path)
        possible_matches = extract_host_from_domain(complete_path)
        possible_matches.push(DEFAULT_PROCESS_NAME)
        exact_match = nil
        possible_matches.each do |match|
          if match
            exact_match = dns_check(process_name: match)
            break if exact_match.port
          end
        end
        exact_match
      end

      def extract_host_from_domain(complete_path)
        matching_strings = []
        tld_match_regex.map do |regexp|
          if (match_result = complete_path.match(regexp))
            matching_strings << match_result[1]
          end
        end
        matching_strings.uniq
      end

      private

      def tld_match_regex
        tld = Invoker.config.tld
        [/([\w.-]+)\.#{tld}(\:\d+)?$/, /([\w-]+)\.#{tld}(\:\d+)?$/]
      end

      def dns_check(dns_args)
        Invoker::IPC::UnixClient.send_command("dns_check", dns_args) do |dns_response|
          dns_response
        end
      end
    end
  end
end
