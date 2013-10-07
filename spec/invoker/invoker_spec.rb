require "spec_helper"

describe "Invoker" do
  describe "#darwin?" do
    it "should return true on osx" do
      Invoker.expects(:ruby_platform).returns("x86_64-darwin12.4.0")
      Invoker.darwin?.should == true
    end

    it "should return false on linux" do
      Invoker.expects(:ruby_platform).returns("i686-linux")
      Invoker.darwin?.should == false
    end
  end

  describe "#can_run_balancer?" do
    before {
      File.exists?(Invoker::Power::Config::CONFIG_LOCATION) &&
      File.delete(Invoker::Power::Config::CONFIG_LOCATION)
    }

    after {
      File.exists?(Invoker::Power::Config::CONFIG_LOCATION) &&
      File.delete(Invoker::Power::Config::CONFIG_LOCATION)
    }

    it "should return false if setup command was not run on osx" do
      Invoker.expects(:ruby_platform).returns("x86_64-darwin12.4.0")
      Invoker.can_run_balancer?.should ==false
    end

    it "should return false if platform is not osx" do
      Invoker.expects(:ruby_platform).returns("i686-linux")
      Invoker.can_run_balancer?.should == false
    end

    it "should return true if setup was run properly" do
      Invoker.expects(:ruby_platform).returns("x86_64-darwin12.4.0")
      File.open(Invoker::Power::Config::CONFIG_LOCATION, "w") {|fl|
        fl.write("hello")
      }

      Invoker.can_run_balancer?.should === true
    end

    it "should not print warning if setup is not run when flag is false" do
      Invoker.expects(:ruby_platform).returns("x86_64-darwin12.4.0")
      Invoker::Logger.expects(:puts).never()
      Invoker.can_run_balancer?(false)
    end
  end
end

