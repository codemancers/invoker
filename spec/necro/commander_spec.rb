require "spec_helper"

describe "Necro::Commander" do
  
  describe "With no processes configured" do
    before do
      @commander = Necro::Commander.new()
    end
    
    it "should throw error" do
      necro_config.stubs(:processes).returns([])

      lambda {
        @commander.start_manager()
      }.should.raise(Necro::Errors::InvalidConfig)
    end
  end

  describe "#add_command_by_label" do
    before do
      @commander = Necro::Commander.new()
    end

    it "should find command by label and start it, if found" do
      necro_config.stubs(:processes).returns([OpenStruct.new(:label => "resque", :cmd => "foo", :dir => "bar")])
      @commander.expects(:add_command).returns(true)
      
      @commander.add_command_by_label("resque")
    end
  end

  describe "#remove_command" do
    before do
      @commander = Necro::Commander.new()
      @commander.workers.expects(:[]).returns(OpenStruct.new(:pid => "bogus"))
    end

    describe "if a signal is specified" do
      it "should use that signal to kill the worker" do
        @commander.remove_command("resque", "HUP")
        @commander.expects(:process_kill)
      end
    end

    describe "if signal specified is integer" do
      it "should convert that signal to integer" do
      end
    end

    describe "if no signal is specified" do
      it "should use INT signal" do
      end
    end
  end

  describe "#add_command" do
    it "should populate workers and open_pipes" do
    end
  end

end
