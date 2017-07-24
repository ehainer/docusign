module Docusign
  module ActiveRecord

    def documentable
      has_many :envelopes, as: :envelopable, inverse_of: :envelopable, validate: true, autosave: true, class_name: '::Docusign::Envelope'
      has_many :templates, as: :templatable, inverse_of: :templatable, validate: true, autosave: true, class_name: '::Docusign::Template'
    end

  end
end