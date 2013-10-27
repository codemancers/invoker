require "spec_helper"
require "tempfile"

describe Invoker::Power::HttpResponse do
  before do
    @http_response = Invoker::Power::HttpResponse.new()
  end

  it "should allow user to send a file" do
    begin
      file = Tempfile.new("error.html")
      file_content = "Error message"
      file.write(file_content)
      file.close

      @http_response.use_file_as_body(file.path)
      expect(@http_response.body).to eq(file_content)
      expect(@http_response.http_string).to include(file_content)
    ensure
      file.unlink
    end
  end

  it "should allow user to set headers" do
    @http_response["Content-Type"] = "text/html"
    expect(@http_response.header["Content-Type"]).to eq("text/html")
    expect(@http_response.http_string).to include("Content-Type")
  end

  it "should allow user to set status" do
    @http_response.status = 503
    expect(@http_response.http_string).to include(Invoker::Power::HttpResponse::STATUS_MAPS[503])
  end
end
