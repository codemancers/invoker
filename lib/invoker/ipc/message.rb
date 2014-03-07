module Invoker
  module IPC
    module Message
      module Serialization
        def self.included(base)
          base.extend ClassMethods
        end

        def to_json
          attributes.to_json
        end

        module ClassMethods
          def from_json_string(string_data)
            from_ruby_object(parser.parse(string_data))
          end

          def from_io(io)
            from_ruby_object(parser.parse(io))
          end

          def from_ruby_object(ruby_object)
          end

          def parser
            Yajl::Parser.new
          end
        end
      end

      class Add < Struct(:command_name)
      end
    end
  end
end
