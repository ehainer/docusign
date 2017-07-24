Docusign.setup do |config|

  # Docusign username
  config.username = 'eric@commercekitchen.com'

  # Docusign password
  config.password = 'fSQ-8$?^3_H9faY#BnJR=Qq#VHH2?-@-'

  # Docusign integrator key
  config.key = 'COMM-e3adeeb4-8021-4e4f-a8e6-f17484e330b5'

  # Docusign account id
  config.account_id = '544544'

  # Docusign api endpoint url. If not in production, use `https://demo.docusign.net/restapi`
  config.endpoint = 'https://demo.docusign.net/restapi'

  # The Docusign "tabs" that can be generated. This list defines the tab methods `<tab_name>_at`
  # For a full list of possible tabs, see https://docs.docusign.com/esign/restapi/Envelopes/Envelopes/create/#/definitions/EnvelopeRecipientTabs
  config.tabs = [:approve, :checkbox, :company, :date_signed, :date, :decline, :email_address, :email, :envelope_id, :first_name, :formula, :full_name, :initial_here, :last_name, :list, :note, :number, :radio_group, :signer_attachment, :sign_here, :ssn, :text, :title, :view, :zip]

end
