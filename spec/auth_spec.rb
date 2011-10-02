require 'spec_helper'

describe 'auth' do
  it "sends Authentication header" do
    ifirma = Ifirma.new :config => { :username => "drogus", :invoices_key => "AABB" }

    headers = {
      'Accept' => 'application/json',
      'Accept-Encoding' => /gzip/,
      'Authentication' => 'IAPIS user=drogus, hmac-sha1=45a7b2125964c117cc411b894517a4317ceee9',
      'Content-Type' => 'application/json; charset=utf-8',
      'User-Agent' => 'Ruby'
    }

    stub_request(:get, "https://www.ifirma.pl/iapi/foo").
      with(:headers => headers).to_return(:body => "abc")

    ifirma.get("/iapi/foo")
  end
end

