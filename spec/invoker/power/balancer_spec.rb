require 'spec_helper'

describe Invoker::Power::Balancer do
  context "matching domain part of incoming request" do
    before do
      @balancer = Invoker::Power::Balancer.new(mock("connection"))
    end

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
      expect(matching_string).to eq("bar")
    end

    it "should match hello-world.dev" do
      match = @balancer.extract_host_from_domain("hello-world.dev")
      expect(match).to_not be_nil

      matching_string = match[1]
      expect(matching_string).to eq("hello-world")
    end
  end
end
