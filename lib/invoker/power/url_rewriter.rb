module Invoker
  module Power
    class UrlRewriter
      DEV_MATCH_REGEX = [/([\w.-]+)\.dev(\:\d+)?$/, /([\w-]+)\.dev(\:\d+)?$/]

      def select_backend_config(complete_path)
        possible_matches = extract_host_from_domain(complete_path)
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
        DEV_MATCH_REGEX.map do |regexp|
          if (match_result = complete_path.match(regexp))
            matching_strings << match_result[1]
          end
        end
        matching_strings.uniq
      end

      private

      def dns_check(dns_args)
        Invoker::IPC::UnixClient.send_command("dns_check", dns_args) do |dns_response|
          dns_response
        end
      end
    end
  end
end
