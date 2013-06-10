require "spec_helper"

describe Invoker::CommandListener::Client do
  describe "add command" do
    before do
      @client_socket = mock()
      @client = Invoker::CommandListener::Client.new(@client_socket)
    end
    
    it "should run if read from socket" do
      invoker_commander.expects(:add_command_by_label).with("foo")
      @client_socket.expects(:read).returns("add foo\n")
      @client_socket.expects(:close)

      @client.read_and_execute()
    end
  end

  describe "remove command" do
    before do
      @client_socket = mock()
      @client = Invoker::CommandListener::Client.new(@client_socket)
    end

    it "with specific signal" do
      invoker_commander.expects(:remove_command).with("foo", "9")
      @client_socket.expects(:read).returns("remove foo 9\n")
      @client_socket.expects(:close)

      @client.read_and_execute()
    end

    it "with default signal" do
      invoker_commander.expects(:remove_command).with("foo",nil)
      @client_socket.expects(:read).returns("remove foo\n")
      @client_socket.expects(:close)

      @client.read_and_execute()
    end
  end

  describe "invalid command" do
    before do
      @client_socket = mock()
      @client = Invoker::CommandListener::Client.new(@client_socket)
    end

    it "should print error if read from socket" do
      invoker_commander.expects(:remove_command).never()
      invoker_commander.expects(:add_command_by_label).never()
      @client_socket.expects(:read).returns("eugh foo\n")
      @client_socket.expects(:close)

      @client.read_and_execute
    end
  end
end
