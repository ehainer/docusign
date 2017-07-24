require 'spec_helper'

describe Docusign::DocumentHelper do

  before(:each) do
    WebMock.allow_net_connect!
  end

  after(:each) do
    WebMock.disable_net_connect!
  end
  
  let(:envelope) do
    begin
      Docusign::Envelope.create!(email_subject: Faker::Name.title, status: :sent) do |e|
        e.add_document(file_fixture('pdf1.pdf').expand_path)
        e.add_signer(name: Faker::Name.name, email: 'sample@example.org')
      end
    rescue => e
      envelope = Docusign::Envelope.new(email_subject: Faker::Name.title, status: :sent) do |e|
        e.add_document(file_fixture('pdf1.pdf').expand_path)
        e.add_signer(name: Faker::Name.name, email: 'sample@example.org')
      end
      puts envelope.send(:create_payload)
      puts e.backtrace
    end
  end

  it 'can create embedded document markup' do
    w = [*1000..3000].sample
    h = [*1000..3000].sample
    iframe = embedded_document(envelope, width: w, height: h)
    expect(iframe).to include("<iframe width=\"#{w}\" height=\"#{h}\"")
    expect(iframe).to include('https://demo.docusign.net/Signing/startinsession.aspx')
  end

end