module Invoker
  module Power
    class HttpParser
      attr_accessor :host, :parser, :protocol
      attr_accessor :raw_header_data

      def initialize(protocol)
        @protocol = protocol
        @parser = HTTP::Parser.new
        @header = {}
        @raw_header_data = StringIO.new
        @headers_parsed = false
        @body = nil

        parser.on_headers_complete { complete_headers_received }
        parser.on_header_field { |field_name| @last_key = field_name }
        parser.on_header_value { |field_value| header_value_received(field_value) }
        parser.on_body { |body| @body = body }

        parser.on_message_complete { complete_message_received }
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
        @raw_header_data = StringIO.new
        @headers_parsed = false
        @body = nil
        parser.reset
      end

      def << data
        @raw_header_data.write(data) unless headers_parsed?
        parser << data
      end

      private

      def complete_message_received
        header_string = @raw_header_data.string.dup
        puts header_string.inspect
        if header_string =~ /\r\n\r\n/m && header_string !~ /X_FORWARDED_PROTO/i
          header_string.gsub!(/\r\n\r\n/, "\r\nX_FORWARDED_PROTO: #{protocol}\r\n\r\n")
        end

        if @body
          full_message = header_string + @body
        else
          full_message = header_string
        end

        if @on_message_complete_callback
          @on_message_complete_callback.call(full_message)
        end
      end

      def headers_parsed?
        @headers_parsed
      end

      # gets invoker when complete header is received
      def complete_headers_received
        @headers_parsed = true
        if @on_headers_complete_callback
          @on_headers_complete_callback.call(@header)
        end
      end
    end
  end
end
