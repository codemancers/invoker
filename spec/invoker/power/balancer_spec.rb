require 'spec_helper'

describe Invoker::Power::Balancer do
  before do
    @balancer = Invoker::Power::Balancer.new(mock("connection"), "http")
  end

  context "matching domain part of incoming request" do
    it "should do foo.dev match" do
      match = @balancer.extract_host_from_domain("foo.dev")
      expect(match).to_not be_nil

      matching_string = match[1]
      expect(matching_string).to eq("foo")
    end

    it "should match foo.dev:1080" do
      match = @balancer.extract_host_from_domain("foo.dev:1080")
      expect(match).to_not be_nil

      matching_string = match[1]
      expect(matching_string).to eq("foo")
    end

    it "should match emacs.bar.dev" do
      match = @balancer.extract_host_from_domain("emacs.bar.dev")
      expect(match).to_not be_nil

      matching_string = match[1]
      expect(matching_string).to eq("emacs.bar")
    end

    it "should match hello-world.dev" do
      match = @balancer.extract_host_from_domain("hello-world.dev")
      expect(match).to_not be_nil

      matching_string = match[1]
      expect(matching_string).to eq("hello-world")
    end
  end

  context "matching domain part of incoming request using xip.io" do
    it "should do foo.10.0.0.1.xip.io match" do
      match = @balancer.extract_host_from_domain("foo.10.0.0.1.xip.io")
      expect(match).to_not be_nil

      matching_string = match[1]
      expect(matching_string).to eq("foo")
    end

    it "should match foo.10.0.0.1.xip.io:1080" do
      match = @balancer.extract_host_from_domain("foo.10.0.0.1.xip.io:1080")
      expect(match).to_not be_nil

      matching_string = match[1]
      expect(matching_string).to eq("foo")
    end

    it "should match emacs.bar.10.0.0.1.xip.io" do
      match = @balancer.extract_host_from_domain("emacs.bar.10.0.0.1.xip.io")
      expect(match).to_not be_nil

      matching_string = match[1]
      expect(matching_string).to eq("bar")
    end

    it "should match hello-world.10.0.0.1.xip.io" do
      match = @balancer.extract_host_from_domain("hello-world.10.0.0.1.xip.io")
      expect(match).to_not be_nil

      matching_string = match[1]
      expect(matching_string).to eq("hello-world")
    end
  end
end
