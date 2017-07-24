require 'spec_helper'

describe Docusign::Client do

  let(:client) { Docusign::Client.new }

  it 'can make a GET request' do
    stub_request(:get, "http://localhost/posts/1").
         with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby'}).
         to_return(status: 200, body: "{\"status\":\"got\"}", headers: {})
    response = client.get('http://localhost/posts/1')
    expect(response).to be_an_instance_of(Docusign::Response)
    expect(response.response.code).to eq('200')
    expect(response.status).to eq('got')
  end

  it 'can make a DELETE request' do
    stub_request(:delete, "http://localhost/posts/1").
         with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby'}).
         to_return(status: 200, body: "{\"status\":\"deleted\"}", headers: {})
    response = client.delete('http://localhost/posts/1')
    expect(response).to be_an_instance_of(Docusign::Response)
    expect(response.response.code).to eq('200')
    expect(response.status).to eq('deleted')
  end

  it 'can make a PUT request' do
    stub_request(:put, "https://localhost/posts/1").
         with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby'}).
         to_return(status: 200, body: "{\"status\":\"put\"}", headers: {})
    response = client.put('https://localhost/posts/1')
    expect(response).to be_an_instance_of(Docusign::Response)
    expect(response.response.code).to eq('200')
    expect(response.status).to eq('put')
  end

  it 'can make a POST request' do
    stub_request(:post, "http://localhost/posts/1").
         with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby'}).
         to_return(status: 200, body: "{\"status\":\"posted\"}", headers: {})
    response = client.post('http://localhost/posts/1')
    expect(response).to be_an_instance_of(Docusign::Response)
    expect(response.response.code).to eq('200')
    expect(response.status).to eq('posted')
  end

  it 'will respond with a parse error if the body could not be decoded' do
    stub_request(:post, "http://localhost/posts/error").
         with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby'}).
         to_return(status: 200, body: "this_is_not_valid_json", headers: {})
    response = client.post('http://localhost/posts/error')
    expect(response.error?).to eq(true)
    expect(response.code).to eq('PARSE_ERROR')
  end

  it 'will retrieve api information' do
    WebMock.allow_net_connect!
    expect(client.information.login_accounts).to be_present
    expect(client.information.login_accounts).to be_a(Array)
    WebMock.disable_net_connect!
  end

end