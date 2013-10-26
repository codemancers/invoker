module Invoker
  module Power
    class HttpResponse
      def status_maps(status)
        {
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
        }[status]
      end

      attr_accessor :header, :body, :status

      def initialize
        @header = {}
        header['Server'] = "Invoker 1.1"
        header['Date'] = Time.now
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
        final_string << "HTTP/1.1 #{status} #{status_maps(status)}"

        if header['Transfer-Encoding'].nil? && body.empty?
          header['Content-Length'] = body.length
        end

        if cache_control = header['Cache-Control']
          final_string << "Cache-Control: #{cache_control}"
        end

        if connection = header['Connection']
          final_string << "Connection: #{connection}"
        end

        if date = header['Date']
          final_string << "Date: #{date}"
        end

        if pragma = header['Pragma']
          final_string << "Pragma: #{pragma}"
        end

        if trailer = header['Trailer']
          final_string << "Trailer: #{trailer}"
        end

        if transefer_encoding = header['Transfer-Encoding']
          final_string << "Transfer-Encoding: #{transefer_encoding}"
        end

        if accept_ranges = header['Accept-Ranges']
          final_string << "Accept-Ranges: #{accept_ranges}"
        end

        if age = header['Age']
          final_string << "Age: #{age}"
        end

        if etag = header['Etag']
          final_string << "Etag: #{etag}"
        end

        if server = header['Server']
          final_string << "Server: #{server}"
        end

        if location = header['Location']
          final_string << "Location: #{location}"
        end

        if allow = header['Allow']
          final_string << "Allow: #{allow}"
        end

        if content_encoding = header['Content-Encoding']
          final_string << "Content-Encoding: #{content_encoding}"
        end

        if content_length = header['Content-Length']
          final_string << "Content-Length: #{content_length}"
        end

        if content_language = header['Content-Language']
          final_string << "Content-Language: #{content_language}"
        end

        if content_location = header['Content-Location']
          final_string << "Content-Location: #{content_location}"
        end

        if content_md5 = header['Content-MD5']
          final_string << "Content-MD5: #{content_md5}"
        end

        if content_range = header['Content-Range']
          final_string << "Content-Range: #{content_range}"
        end

        if content_type = header['Content-Type']
          final_string << "Content-Type: #{content_type}"
        end

        if expires = header['Expires']
          final_string << "Expires: #{expires}"
        end

        if last_modified = header['Last-Modified']
          final_string << "Last-Modified: #{last_modified}"
        end

        if extension_header = header['extension-header']
          final_string << "extension_header: #{extension_header}"
        end

        final_string.join("\r\n") + "\r\n\r\n" + body
      end
    end
  end
end
