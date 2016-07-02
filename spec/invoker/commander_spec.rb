require "spec_helper"

describe "Invoker::Commander" do
  before(:each) do
    @original_invoker_config = Invoker.config
    Invoker.config = mock
  end

  after(:each) do
    Invoker.config = @original_invoker_config
  end

  describe "With no processes configured" do
    before(:each) do
      @commander = Invoker::Commander.new
    end

    it "should throw error" do
      Invoker.config.stubs(:processes).returns([])

      expect {
        @commander.start_manager
      }.to raise_error(Invoker::Errors::InvalidConfig)
    end
  end

  describe "#start_process" do
    describe "when not daemonized" do
      before do
        processes = [OpenStruct.new(:label => "foobar", :cmd => "foobar_command", :dir => ENV['HOME'])]
        Invoker.config.stubs(:processes).returns(processes)
        Invoker.config.stubs(:autorunnable_processes).returns(processes)
        Invoker.stubs(:can_run_balancer?).returns(false)
        @commander = Invoker::Commander.new
        Invoker.commander = @commander
      end

      after do
        Invoker.commander = nil
      end

      it "should populate workers and open_pipes" do
        @commander.expects(:start_event_loop)
        @commander.process_manager.expects(:load_env).returns({})
        @commander.process_manager.expects(:spawn).returns(100)
        @commander.process_manager.expects(:wait_on_pid)
        @commander.expects(:at_exit)
        @commander.start_manager
        expect(@commander.process_manager.open_pipes).not_to be_empty
        expect(@commander.process_manager.workers).not_to be_empty

        worker = @commander.process_manager.workers['foobar']

        expect(worker).not_to be_nil
        expect(worker.command_label).to eq('foobar')

        pipe_end_worker = @commander.process_manager.open_pipes[worker.pipe_end.fileno]
        expect(pipe_end_worker).not_to be_nil
      end
    end

    describe "when daemonized" do
      before do
        processes = [OpenStruct.new(:label => "foobar", :cmd => "foobar_command", :dir => ENV['HOME'])]
        Invoker.config.stubs(:processes).returns(processes)
        Invoker.config.stubs(:autorunnable_processes).returns(processes)
        Invoker.stubs(:can_run_balancer?).returns(false)
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
        @commander.process_manager.expects(:load_env).returns({})
        Invoker.daemon.expects(:start).once
        @commander.process_manager.expects(:spawn).returns(100)
        @commander.process_manager.expects(:wait_on_pid)
        @commander.expects(:at_exit)
        @commander.start_manager

        expect(@commander.process_manager.open_pipes).not_to be_empty
        expect(@commander.process_manager.workers).not_to be_empty

        worker = @commander.process_manager.workers['foobar']

        expect(worker).not_to be_nil
        expect(worker.command_label).to eq('foobar')

        pipe_end_worker = @commander.process_manager.open_pipes[worker.pipe_end.fileno]
        expect(pipe_end_worker).not_to be_nil
      end
    end
  end

  describe 'disable_autorun option' do
    context 'autorun is disabled for a process' do
      before do
        @processes = [
          OpenStruct.new(:label => "foobar", :cmd => "foobar_command", :dir => ENV['HOME']),
          OpenStruct.new(:label => "panda", :cmd => "panda_command", :dir => ENV['HOME'], :disable_autorun => true)
        ]
        Invoker.config.stubs(:processes).returns(@processes)
        Invoker.config.stubs(:autorunnable_processes).returns([@processes.first])

        @commander = Invoker::Commander.new
      end

      it "doesn't run process" do
        @commander.expects(:install_interrupt_handler)
        @commander.process_manager.expects(:run_power_server)
        @commander.expects(:at_exit)
        @commander.expects(:start_event_loop)

        @commander.process_manager.expects(:start_process).with(@processes[0])
        @commander.process_manager.expects(:start_process).with(@processes[1]).never
        @commander.start_manager
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
