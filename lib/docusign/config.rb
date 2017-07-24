module Docusign
  class Config

    attr_accessor :username, :password, :key, :account_id

    attr_writer :endpoint, :version, :tabs

    def initialize
      @endpoint ||= 'https://www.docusign.net/restapi'
      @version ||= 'v2'
      @tabs ||= [:approve, :checkbox, :company, :date_signed, :date, :decline, :email_address, :email, :envelope_id, :first_name, :formula, :full_name, :initial_here, :last_name, :list, :note, :number, :radio_group, :signer_attachment, :sign_here, :ssn, :text, :title, :view, :zip]
    end

    def endpoint
      @endpoint.to_s.gsub(/\/+$/, '')
    end

    def version
      @version.to_s.gsub(/(^\/+)|(\/+$)/, '')
    end

    def tabs
      Array.wrap(@tabs).map { |tab| tab.to_s.underscore }
    end

  end
end