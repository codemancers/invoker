require "spec_helper"

describe "PortFinder" do
  before do
    @port_finder = Invoker::Power::PortFinder.new()
    @port_finder.find_ports
  end

  it "should find a http port" do
    @port_finder.http_port.should_not == nil
  end

  it "should find a dns port" do
    @port_finder.dns_port.should_not == nil
  end
end
