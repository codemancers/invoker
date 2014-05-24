require "spec_helper"

describe "Setup" do
  describe "setup on non osx systems" do
    it "should not run setup" do
      Invoker.expects(:ruby_platform).returns("i686-linux")
      Invoker::Power::Setup.any_instance.expects(:check_if_setup_can_run?).never()
      Invoker::Power::Setup.install
    end
  end
end
