require "spec_helper"

describe "Invoker::Commander" do
  describe "With no processes configured" do
    before do
      @commander = Invoker::Commander.new
    end

    it "should throw error" do
      invoker_config.stubs(:processes).returns([])

      expect {
        @commander.start_manager
      }.to raise_error(Invoker::Errors::InvalidConfig)
    end
  end

  describe "#start_process" do
    describe "when not daemonized" do
      before do
        invoker_config.stubs(:processes).returns([OpenStruct.new(:label => "sleep", :cmd => "sleep 4", :dir => ENV['HOME'])])
        @commander = Invoker::Commander.new
        Invoker.commander = @commander
      end

      after do
        Invoker.commander = nil
      end

      it "should populate workers and open_pipes" do
        @commander.expects(:start_event_loop)
        @commander.expects(:load_env).returns({})
        @commander.start_manager
        expect(@commander.open_pipes).not_to be_empty
        expect(@commander.workers).not_to be_empty

        worker = @commander.workers['sleep']

        expect(worker).not_to be_nil
        expect(worker.command_label).to eq('sleep')

        pipe_end_worker = @commander.open_pipes[worker.pipe_end.fileno]
        expect(pipe_end_worker).not_to be_nil
      end
    end

    describe "when daemonized" do
      before do
        invoker_config.stubs(:processes).returns([OpenStruct.new(:label => "sleep", :cmd => "sleep 4", :dir => ENV['HOME'])])
        @commander = Invoker::Commander.new
        Invoker.commander = @commander
        Invoker.daemonize = true
      end

      after do
        Invoker.commander = nil
        Invoker.daemonize = false
      end

      it "should daemonize the process and populate workers and open_pipes" do
        @commander.expects(:start_event_loop)
        @commander.expects(:load_env).returns({})
        Invoker.daemon.expects(:start).once
        @commander.start_manager

        expect(@commander.open_pipes).not_to be_empty
        expect(@commander.workers).not_to be_empty

        worker = @commander.workers['sleep']

        expect(worker).not_to be_nil
        expect(worker.command_label).to eq('sleep')

        pipe_end_worker = @commander.open_pipes[worker.pipe_end.fileno]
        expect(pipe_end_worker).not_to be_nil
      end
    end
  end

  describe "#runnables" do
    before do
      @commander = Invoker::Commander.new
    end

    it "should run runnables in reactor tick with one argument" do
      @commander.on_next_tick("foo") { |cmd| start_process_by_name(cmd) }
      @commander.expects(:start_process_by_name).returns(true)
      @commander.run_runnables()
    end

    it "should run runnables with multiple args" do
      @commander.on_next_tick("foo", "bar", "baz") { |t1,*rest|
        stop_process(t1, rest)
      }
      @commander.expects(:stop_process).with("foo", ["bar", "baz"]).returns(true)
      @commander.run_runnables()
    end

    it "should run runnable with no args" do
      @commander.on_next_tick() { hello() }
      @commander.expects(:hello).returns(true)
      @commander.run_runnables()
    end
  end
end
