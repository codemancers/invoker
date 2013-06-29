require "spec_helper"

describe Invoker::CommandListener::Client do
  describe "add command" do
    before do
      @client_socket = mock()
      @client = Invoker::CommandListener::Client.new(@client_socket)
    end
    
    it "should run if read from socket" do
      invoker_commander.expects(:on_next_tick).with("foo")
      @client_socket.expects(:gets).returns("add foo\n")

      @client.read_and_execute()
    end
  end

  describe "remove command" do
    before do
      @client_socket = mock()
      @client = Invoker::CommandListener::Client.new(@client_socket)
    end

    it "with specific signal" do
      invoker_commander.expects(:on_next_tick).with("foo", "9")
      @client_socket.expects(:gets).returns("remove foo 9\n")

      @client.read_and_execute()
    end

    it "with default signal" do
      invoker_commander.expects(:on_next_tick).with("foo",nil)
      @client_socket.expects(:gets).returns("remove foo\n")

      @client.read_and_execute()
    end
  end

  describe "invalid command" do
    before do
      @client_socket = mock()
      @client = Invoker::CommandListener::Client.new(@client_socket)
    end

    it "should print error if read from socket" do
      invoker_commander.expects(:on_next_tick).never()
      @client_socket.expects(:gets).returns("eugh foo\n")

      @client.read_and_execute
    end
  end
end
