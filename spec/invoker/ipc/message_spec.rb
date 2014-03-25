require "spec_helper"

describe Invoker::IPC::Message do
  describe "test equality of objects" do
    context "for simple messages" do
      let(:message) { MM::Add.new(process_name: 'foo') }

      it "object should be reported same if same value" do
        m2 = MM::Add.new(process_name: 'foo')
        expect(message).to eql m2
      end

      it "should report objects to be not eql if differnt value" do
        m2 = MM::Add.new(process_name: 'bar')
        expect(message).to_not eql m2
      end
    end

    context "for nested messages" do
      let(:process_array) do
        [
          { shell_command: 'foo', process_name: 'foo', dir: '/tmp', pid: 100 },
          { shell_command: 'bar', process_name: 'bar', dir: '/tmp', pid: 200 }
        ]
      end

      let(:message) { MM::ListResponse.new(processes: process_array) }

      it "should report eql for eql objects" do
        m2 = MM::ListResponse.new(processes: process_array)
        expect(message).to eql m2
      end

      it "should report not equal for different objects" do
        another_process_array = [
          { shell_command: 'baz', process_name: 'foo', dir: '/tmp', pid: 100 },
          { shell_command: 'bar', process_name: 'bar', dir: '/tmp', pid: 200 }
        ]

        m2 = MM::ListResponse.new(processes: another_process_array)
        expect(message).to_not eql m2
      end
    end
  end
end
