require 'spec_helper'

describe Invoker::Power::Balancer do
  context "matching domain part of incoming request" do
    it "should do foo.dev match" do
      match = "foo.dev".match(Invoker::Power::Balancer::DEV_MATCH_REGEX)
      expect(match).to_not be_nil

      matching_string = match[1]
      expect(matching_string).to eq("foo")
    end

    it "should match foo.dev:1080" do
      match = "foo.dev:1080".match(Invoker::Power::Balancer::DEV_MATCH_REGEX)
      expect(match).to_not be_nil

      matching_string = match[1]
      expect(matching_string).to eq("foo")
    end

    it "should match emacs.bar.dev" do
      match = "emacs.bar.dev".match(Invoker::Power::Balancer::DEV_MATCH_REGEX)
      expect(match).to_not be_nil

      matching_string = match[1]
      expect(matching_string).to eq("bar")
    end

    it "should match hello-world.dev" do
      match = "hello-world.dev".match(Invoker::Power::Balancer::DEV_MATCH_REGEX)
      expect(match).to_not be_nil

      matching_string = match[1]
      expect(matching_string).to eq("hello-world")
    end
  end
end
