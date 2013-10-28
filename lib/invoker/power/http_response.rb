require 'time'

module Invoker
  module Power
    class HttpResponse
      STATUS_MAPS = {
        200 => "OK",
        201 => "Created",
        202 => "Accepted",
        204 => "No Content",
        205 => "Reset Content",
        206 => "Partial Content",
        301 => "Moved Permanently",
        302 => "Found",
        304 => "Not Modified",
        400 => "Bad Request",
        401 => "Unauthorized",
        402 => "Payment Required",
        403 => "Forbidden",
        404 => "Not Found",
        411 => "Length Required",
        500 => "Internal Server Error",
        501 => "Not Implemented",
        502 => "Bad Gateway",
        503 => "Service Unavailable",
        504 => "Gateway Timeout"
      }

      HTTP_HEADER_FIELDS = [
        'Cache-Control', 'Connection', 'Date',
        'Pragma', 'Trailer', 'Transfer-Encoding',
        'Accept-Ranges', 'Age', 'Etag',
        'Server', 'Location', 'Allow',
        'Content-Encoding', 'Content-Language', 'Content-Location',
        'Content-MD5', 'Content-Range',
        'Content-Type', 'Expires',
        'Last-Modified', 'extension-header'
      ]

      attr_accessor :header, :body, :status

      def initialize
        @header = {}
        header['Server'] = "Invoker 1.1"
        header['Date'] = Time.now.httpdate
        @status = 200
        @body = ""
      end

      def []=(key, value)
        header[key] = value
      end

      def use_file_as_body(file_name)
        if file_name && File.exists?(file_name)
          file_content = File.read(file_name)
          self.body = file_content
        else
          raise Invoker::Errors:InvalidFile, "Invalid file as body"
        end
      end

      def http_string
        final_string = []
        final_string << "HTTP/1.1 #{status} #{STATUS_MAPS[status]}"

        if header['Transfer-Encoding'].nil? && body.empty?
          header['Content-Length'] = body.length
        end

        HTTP_HEADER_FIELDS.each do |key|
          if value = header[key]
            final_string << "#{key}: #{value}"
          end
        end

        final_string.join("\r\n") + "\r\n\r\n" + body
      end
    end
  end
end
