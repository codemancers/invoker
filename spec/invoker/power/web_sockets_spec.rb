require 'spec_helper'

# Full integration test. Start a server, and client. Let client interact with
# server do a ping-pong. Client checks whether ping pong is successful or not.
# Also, mock rewriter so that it returns valid port for request proxying.
# - Server will run on port 28080.
# - Balancer will run on port 28081 proxying to 28080
# - Client will connect to 28081 performing ping-pong

def websocket_server
  require 'websocket-eventmachine-server'

  EM.run do
    WebSocket::EventMachine::Server.start(host: "0.0.0.0", port: 28080) do |ws|
      ws.onerror { |e| p e }
      ws.onmessage { ws.send "pong" }
    end

    EM.add_timer(2) { EM.stop }
  end
end

def websocket_client
  require 'websocket-eventmachine-client'

  @message = ""

  EM.run do
    ws = WebSocket::EventMachine::Client.connect(uri: 'ws://0.0.0.0:28081')
    ws.onerror { |e| p e }
    ws.onopen { ws.send("ping") }
    ws.onmessage { |m, _| @message = m }

    EM.add_timer(2) do
      expect(@message).to eq "pong"
      EM.stop
    end
  end
end


describe 'Web sockets support' do
  it 'can ping pong via balancer' do
    dns_response = Struct.new(:port).new(28080)
    Invoker::Power::UrlRewriter.any_instance
      .stubs(:select_backend_config)
      .returns(dns_response)

    EM.run do
      EM.start_server("0.0.0.0", 28081, EM::ProxyServer::Connection, {}) do |conn|
        Invoker::Power::Balancer.new(conn, "http").install_callbacks
      end

      fork { websocket_server }
      fork { websocket_client }
      EM.add_timer(3) { EM.stop }
    end

    Process.waitall
  end
end
