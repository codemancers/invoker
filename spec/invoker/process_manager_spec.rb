require "spec_helper"

describe Invoker::ProcessManager do
  let(:process_manager) { Invoker::ProcessManager.new }

  describe '#start_process_or_group_by_name' do
    it 'finds processes by group or process name and starts them' do
      processes_to_start = [
        OpenStruct.new(:label => "postgres", :cmd => "foo", :dir => "bar", :group => "db"),
        OpenStruct.new(:label => "redis", :cmd => "foo", :dir => "bar", :group => "db")
      ]
      invoker_config.expects(:processes_by_group_or_name).with('db').returns(processes_to_start)
      process_manager.expects(:start_process_by_name).with('postgres')
      process_manager.expects(:start_process_by_name).with('redis')
      process_manager.start_process_or_group_by_name('db')
    end
  end

  describe "#start_process_by_name" do
    it "should find command by label and start it, if found" do
      invoker_config.stubs(:processes).returns([OpenStruct.new(:label => "resque", :cmd => "foo", :dir => "bar")])
      invoker_config.expects(:process).returns(OpenStruct.new(:label => "resque", :cmd => "foo", :dir => "bar"))
      process_manager.expects(:start_process).returns(true)

      process_manager.start_process_by_name("resque")
    end

    it "should not start already running process" do
      process_manager.workers.expects(:[]).returns(OpenStruct.new(:pid => "bogus"))
      expect(process_manager.start_process_by_name("resque")).to be_falsey
    end
  end

  describe "#stop_process" do
    let(:message) { MM::Remove.new(options) }
    describe "when a worker is found" do
      before do
        process_manager.workers.expects(:[]).returns(OpenStruct.new(:pid => "bogus"))
      end

      describe "if a signal is specified" do
        let(:options) { { process_name: 'bogus', signal: 'HUP' } }
        it "should use that signal to kill the worker" do
          process_manager.expects(:process_kill).with("bogus", "HUP").returns(true)
          expect(process_manager.stop_process(message)).to be_truthy
        end
      end

      describe "if no signal is specified" do
        let(:options) { { process_name: 'bogus' } }
        it "should use INT signal" do
          process_manager.expects(:process_kill).with("bogus", "INT").returns(true)
          expect(process_manager.stop_process(message)).to be_truthy
        end
      end
    end

    describe "when no worker is found" do
      let(:options) { { process_name: 'bogus', signal: 'HUP' } }
      before do
        process_manager.workers.expects(:[]).returns(nil)
      end

      it "should not kill anything" do
        process_manager.expects(:process_kill).never
        process_manager.stop_process(message)
      end
    end
  end

  describe "#load_env" do
    it "should load .env file from the specified directory" do
      dir = "/tmp"
      begin
        env_file = File.new("#{dir}/.env", "w")
        env_data =<<-EOD
FOO=foo
BAR=bar
        EOD
        env_file.write(env_data)
        env_file.close
        env_options = process_manager.load_env(dir)
        expect(env_options).to include("FOO" => "foo", "BAR" => "bar")
      ensure
        File.delete(env_file.path)
      end
    end

    it "should default to current directory if no directory is specified" do
      dir = ENV["HOME"]
      ENV.stubs(:[]).with("PWD").returns(dir)
      begin
        env_file = File.new("#{dir}/.env", "w")
        env_data =<<-EOD
FOO=bar
BAR=foo
        EOD
        env_file.write(env_data)
        env_file.close
        env_options = process_manager.load_env
        expect(env_options).to include("FOO" => "bar", "BAR" => "foo")
      ensure
        File.delete(env_file.path)
      end
    end

    it "should return empty hash if there is no .env file" do
      dir = "/tmp"
      expect(process_manager.load_env(dir)).to eq({})
    end
  end
end
