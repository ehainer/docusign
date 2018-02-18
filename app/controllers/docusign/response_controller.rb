module Docusign
  class ResponseController < ApplicationController

    def index
      @event = params[:event]
      @message = params[:message]
      @template = "docusign/response/codes/#{@event}"
      @envelope = Docusign::Envelope.find(params[:envelope])
      @signer = Docusign::Signer.find(params[:signer])
      @envelope.sync_status_from_docusign if @envelope.present?
      @signer.update(status: signer_status) if @signer.present?
    end

    private

      def signer_status
        case params[:event]
          when 'access_code_failed', 'disallowed', 'fax_pending', 'id_check_failed'
            'denied'
          when 'cancel'
            'canceled'
          when 'ttl_expired'
            'expired'
          when 'decline'
            'declined'
          when 'signing_complete'
            'signed'
          else
            'pending'
        end
      end

  end
end
