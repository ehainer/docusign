require 'spec_helper'

describe Docusign::Response do

  let(:response) do
    stub_request(:get, "http://localhost/response").
      with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby'}).
      to_return(status: 200, body: { data: { nested: { stuff: 'Hello' }, info: 'Things' } }.to_json, headers: {})
    Docusign::Response.new(Docusign.client.get('http://localhost/response').response)
  end

  it 'allows for nested hash data retrieval using methods' do
    expect(response.data.nested.stuff).to eq('Hello')
  end

  it 'allows methods to specify a default value if data is not found' do
    expect(response.missing('Unknown')).to eq('Unknown')
  end

  it 'will not try and intercept non-read method calls' do
    expect { response.special_thing = 1 }.to raise_error(NoMethodError)
  end

  it 'will have a no response error if provided argument was not an HTTP response object' do
    response = Docusign::Response.new
    expect(response.code).to eq('NO_RESPONSE')
    expect(response.message).to eq('Provided response object was not an instance of Net::HTTPResponse')
  end

end