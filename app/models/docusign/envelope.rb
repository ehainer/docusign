module Docusign
  class Envelope < ::ActiveRecord::Base

    include Rails.application.routes.url_helpers

    mount_uploaders :documents, ::Docusign::DocumentUploader

    serialize :documents, JSON

    has_many :signers, as: :signable

    belongs_to :template, optional: true

    belongs_to :envelopable, polymorphic: true, optional: true

    before_validation :validate_signers

    before_validation :create_envelope, on: :create

    before_validation :update_envelope, on: :update

    after_save :reset_data

    enum status: ['created', 'deleted', 'sent', 'delivered', 'signed', 'completed', 'voided', 'timed_out', 'authoritative_copy', 'transfer_completed', 'template', 'correct']

    accepts_nested_attributes_for :signers

    def add_document(path)
      self.documents ||= []
      self.documents += [File.open(path)]
    end

    def add_signer(**args, &block)
      args = envelopable.try(:to_signer) if args.empty? && envelopable.present?
      signer = self.signers.build(args)
      signer.routing_order = next_route_order
      signer.instance_exec(&block) if block_given?
      signer
    end

    def set_data(key, value=nil)
      if key.is_a?(Hash)
        misc_data.deep_merge!(key.deep_symbolize_keys)
      else
        misc_data[key.to_sym] = value
      end
    end

    def url(recipient=nil, **params)
      # Get the first recipient in the list that has not declined or signed the document
      recipient ||= recipients.find { |recipient| !recipient.declined? && !recipient.signed? }
      params.deep_transform_keys! { |key| key.to_s.underscore.to_sym }
      params[:return_url] ||= docusign_response_url(envelope: id, signer: recipient.try(:id))
      response = Docusign.client.post("envelopes/#{envelope_id}/views/recipient", payload: { authentication_method: :email, user_name: recipient.try(:name), email: recipient.try(:email), client_user_id: recipient.try(:email) }.deep_merge(params))
      if !response.error? && response.url
        response.url
      else
        docusign_response_url(envelope: id, signer: recipient.try(:id), event: :disallowed, message: response.message)
      end
    end

    # TODO: Consider separating instead of concatenating all signers
    def recipients
      (((template rescue nil).try(:signers) || []) + signers).sort_by { |s| s.routing_order.to_i }
    end

    def sync_status_from_docusign
      self.status = docusign_status

      # Skip validations to avoid sending status back up to docusign
      self.save(validate: false)
    end

    alias_method :send!, :sent!

    alias_method :void!, :voided!

    private

      # Get the last routing order from the current recipients, and increase by 1 to get the next order
      def next_route_order
        recipients.map(&:routing_order).compact.sort.last.to_i + 1
      end

      def misc_data
        @misc_data ||= {}
      end

      def create_envelope
        response = Docusign.client.post('envelopes', payload: create_payload)

        if response.error?
          self.errors.add :base, response.message
        else
          self.envelope_id = response.envelope_id
        end
      end

      def update_envelope
        if changed? || !misc_data.blank?
          response = Docusign.client.put("envelopes/#{envelope_id}", payload: update_payload)

          if response.error?
            self.errors.add :base, response.message
          end
        end
      end

      def create_payload
        payload = {
          email_subject: email_subject,
          email_blurb: email_blurb,
          status: sent? ? 'sent' : 'created',
          documents: envelope_documents,
          template_id: template.try(:template_id),
          recipients: {
            signers: envelope_signers
          },
          template_roles: envelope_signers
        }.deep_merge(misc_data)

        # Payload cannot have recipients if a template was specified
        payload.reject! { |k,_| k.to_s == 'recipients' } if payload[:template_id].present?
        payload
      end

      def update_payload
        {
          email_subject: email_subject,
          email_blurb: email_blurb,
          status: sent? ? 'sent' : nil
        }.deep_merge(misc_data)
      end

      def envelope_documents
        idx = 0
        documents.map do |document|
          {
            documentBase64: Base64.encode64(document.read),
            documentId: idx += 1,
            fileExtension: document.file.extension,
            name: document.file.filename
          }
        end
      end

      # Get the hash data of all signers
      def envelope_signers
        signers.map do |signer|
          signer.role_name ||= "Issuer_#{signers.count { |s| s.role_name.present? }+1}"
          signer.to_docusign
        end
      end

      # Ensure each signer has a recipient id before creating
      def validate_signers
        signers.map(&:valid?)
      end

      def reset_data
        @misc_data = {}
      end

      def docusign_status
        Docusign.client.get("envelopes/#{envelope_id}").response_data[:status]
      end

  end
end