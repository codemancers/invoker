module Invoker
  module IPC
    module Message
      module Serialization
        def self.included(base)
          base.extend ClassMethods
        end

        def as_json
          attributes.merge(command: command)
        end

        def message_attributes
          self.class.message_attributes
        end

        def attributes
          message_attribute_keys = message_attributes || []
          message_attribute_keys.inject({}) { |mem, obj| mem[obj] = send(obj); mem }
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

          def message_attributes(*incoming_attributes)
            if incoming_attributes.empty? && defined?(@message_attributes)
              @message_attributes
            else
              @message_attributes ||= []
              new_attributes = incoming_attributes.flatten
              @message_attributes += new_attributes
              attr_accessor * new_attributes
            end
          end

          def parser
            Yajl::Parser.new
          end
        end
      end

      class Base
        def initialize(options)
          options.each do |key, value|
            if self.respond_to?("#{key}=")
              self.key = value
            else
              Invoker::Logger.puts("Ignoring message key #{key} for message #{self.class}")
            end
          end
        end

        def command
          Invoker::IPC.underscore(self.class.name)
        end

        def deliver!
          Socket.unix(Invoker::IPC::Server::SOCKET_PATH) do |socket|
            Yajl::Encoder.encode(as_json, socket)
          end
        end
      end

      class Add < Base
        include Serialization
        message_attributes :process_name
      end

      class Reload < Base
        include Serialization
        message_attributes :process_name, :signal
      end

      class List
        include Serialization
      end

      class Remove < Base
        include Serialization
        message_attributes :process_name, :signal
      end
    end
  end
end
