require 'spec_helper'

describe Docusign do

  before(:each) do
    WebMock.allow_net_connect!
  end

  after(:each) do
    WebMock.disable_net_connect!
  end

  it 'has a version number' do
    expect(Docusign::VERSION).not_to be nil
  end

  context 'Template' do

    let(:template) { Docusign::Template.new(email_subject: Faker::Name.title, name: Faker::Name.title) }

    it 'can be created' do
      expect(template).to be_valid

      @template = Docusign::Template.create!(email_subject: 'Important Document', name: 'Template Name') do |t|
        t.add_document '/web/RedDot/spec/fixtures/files/pdf1.pdf'
      end

      @envelope = Docusign::Envelope.create!(template_id: @template.id, status: :sent) do |e|
        e.add_signer name: 'Eric Hainer', email: 'eric@commercekitchen.com' do
          sign_at 'Known Issues', 0, 125
        end
      end
    end

    it 'requires an email subject' do
      expect(template).to be_valid
      template.email_subject = nil
      expect(template).to_not be_valid
    end

    it 'requires a name' do
      expect(template).to be_valid
      template.name = nil
      expect(template).to_not be_valid
    end

    it 'will have a template id after saving' do
      expect(template.template_id).to be_blank
      template.save
      expect(template.template_id).to_not be_blank
    end

    it 'will have errors from Docusign if data is invalid' do
      expect(template.errors).to be_empty
      template.add_document(file_fixture('fake.pdf').expand_path)
      template.save
      expect(template.errors).to_not be_empty
    end

    it 'can add signers' do
      expect(template.signers.count).to eq(0)
      template.add_signer(name: Faker::Name.name, email: 'sample@example.org')
      template.save
      expect(template.signers.count).to eq(1)
    end

    it 'will route all write method calls to the miscellaneous data' do
      expect(template.send(:misc_data)).to eq({})
      template.enable_wet_sign = false
      expect(template.send(:misc_data)).to eq({ enable_wet_sign: false })
    end

    it 'will not intercept non-write method calls' do
      expect { template.missing }.to raise_error(NoMethodError)
    end

    it 'will clear miscellaneous data after saving' do
      expect(template.send(:misc_data)).to eq({})
      template.enable_wet_sign = false
      expect(template.send(:misc_data)).to eq({ enable_wet_sign: false })
      template.save
      expect(template.send(:misc_data)).to eq({})
    end

    it 'can update the template information' do
      template.save
      expect(template.email_blurb).to be_blank
      template.update(email_blurb: 'Blurb')
      expect(template.errors).to be_empty
    end

    it 'will have errors from Docusign if data is invalid when updating' do
      template.save
      expect(template.errors).to be_empty
      template.enable_wet_sign = 'blahblahblah'
      template.save
      expect(template.errors).to_not be_empty
    end

  end

  context 'Envelope' do

    let(:envelope) { Docusign::Envelope.new }
    let(:template) do
      Docusign::Template.create!(email_subject: Faker::Name.title, name: Faker::Name.title) do |t|
        t.add_signer(name: Faker::Name.name, email: 'sample@example.org')
        t.add_document(file_fixture('pdf1.pdf').expand_path)
      end
    end

    it 'can be created' do
      expect(envelope).to be_valid
    end

    it 'will have an envelope id after saving' do
      expect(envelope.envelope_id).to be_blank
      envelope.save
      expect(envelope.envelope_id).to_not be_blank
    end

    it 'will have errors from Docusign if data is invalid' do
      expect(envelope.errors).to be_empty
      envelope.add_document(file_fixture('fake.pdf').expand_path)
      envelope.save
      expect(envelope.errors).to_not be_empty
    end

    it 'can update the envelope information' do
      envelope.save
      expect(envelope.email_blurb).to be_blank
      envelope.update(email_blurb: 'Blurb')
      expect(envelope.errors).to be_empty
    end

    it 'will have errors from Docusign if data is invalid when updating' do
      envelope.save
      expect(envelope.errors).to be_empty
      envelope.enable_wet_sign = 'blahblahblah'
      envelope.save
      expect(envelope.errors).to_not be_empty
    end

    it 'will route all write method calls to the miscellaneous data' do
      expect(envelope.send(:misc_data)).to eq({})
      envelope.enable_wet_sign = false
      expect(envelope.send(:misc_data)).to eq({ enable_wet_sign: false })
    end

    it 'will redirect to the disallowed page if the embedded document signer is not valid' do
      envelope.save
      expect(envelope.url('Bologne', 'lame@mystery.com')).to eq('http://localhost:3000/docusign/response?event=disallowed&id=1&message=The+recipient+you+have+identified+is+not+a+valid+recipient+of+the+specified+envelope.')
    end

    it 'will use documents and signers from a template if defined' do
      template.save
      envelope.status = 'sent'
      envelope.template_id = template.id
      envelope.add_signer(name: Faker::Name.name, email: 'sample@example.org')
      envelope.add_document(file_fixture('pdf1.pdf').expand_path)
      envelope.save
      puts envelope.errors.full_messages
      expect(envelope.errors).to be_empty
    end

    it 'will not intercept non-write method calls' do
      expect { envelope.missing }.to raise_error(NoMethodError)
    end

  end

  context 'Signer' do

    let(:signer) { Docusign::Signer.new(name: Faker::Name.name, email: 'sample@example.org') }

    it 'will have a recipient id when validated' do
      expect(signer.recipient_id).to be_blank
      signer.valid?
      expect(signer.recipient_id).to_not be_blank
    end

    it 'must have a name' do
      expect(signer).to be_valid
      signer.name = nil
      expect(signer).to_not be_valid
    end

    it 'must have an email' do
      expect(signer).to be_valid
      signer.email = nil
      expect(signer).to_not be_valid
    end

    it 'must have a role name' do
      expect(signer).to be_valid
      signer.role_name = nil
      expect(signer).to_not be_valid
    end

    it 'can define Docusign tabs per the configured tabs' do
      Docusign.config.tabs.each do |tab|
        word = Faker::Lorem.word
        x = [*0..2000].sample
        y = [*0..2000].sample
        signer.send("#{tab}_at", word, x, y)
        expect(signer.tabs["#{tab}_tabs".to_sym]).to eq([{
          anchor_string: word,
          anchor_x_offset: x,
          anchor_y_offset: y
        }])
        signer.tabs = nil
      end
    end

    it 'will route all write method calls to the miscellaneous data' do
      expect(signer.send(:misc_data)).to eq({})
      signer.client_user_id = 'Special ID'
      expect(signer.send(:misc_data)).to eq({ client_user_id: 'Special ID' })
    end

    it 'will not intercept non write method calls that are not defined' do
      expect { signer.missing }.to raise_error(NoMethodError)
    end

  end

end
