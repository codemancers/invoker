module Invoker
  module Power
    class HttpParser
      attr_accessor :host, :parser, :protocol

      def initialize(protocol)
        @protocol = protocol
        @parser = HTTP::Parser.new
        @header = {}
        initialize_message_content
        parser.on_url { |url| url_received(url) }
        parser.on_headers_complete { complete_headers_received }
        parser.on_header_field { |field_name| @last_key = field_name }
        parser.on_header_value { |field_value| header_value_received(field_value) }

        parser.on_message_complete { complete_message_received }
      end

      def on_url(&block)
        @on_url_callback = block
      end

      # define a callback for invoking when complete header is parsed
      def on_headers_complete(&block)
        @on_headers_complete_callback = block
      end

      def header_value_received(value)
        @header[@last_key] = value
      end

      # define a callback to invoke when a full http message is received
      def on_message_complete(&block)
        @on_message_complete_callback = block
      end

      def reset
        @header = {}
        initialize_message_content
        parser.reset
      end

      def << data
        @full_message.write(data)
        parser << data
      end

      private

      def complete_message_received
        full_message_string = @full_message.string.dup
        if full_message_string =~ /\r\n\r\n/
          full_message_string.sub!(/\r\n\r\n/, "\r\nX_FORWARDED_PROTO: #{protocol}\r\n\r\n")
        end
        if @on_message_complete_callback
          @on_message_complete_callback.call(full_message_string)
        end
      end

      def initialize_message_content
        @full_message = StringIO.new
        @full_message.set_encoding('ASCII-8BIT')
      end

      # gets invoker when complete header is received
      def complete_headers_received
        if @on_headers_complete_callback
          @on_headers_complete_callback.call(@header)
        end
      end
      
      def url_received(url)
        if @on_url_callback
          @on_url_callback.call(url)
        end
      end
    end
  end
end
