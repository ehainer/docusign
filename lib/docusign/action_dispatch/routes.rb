module Docusign
  module Routes

    def allow_document_response(options={})
      path = (options[:path] || '/docusign/response').gsub(/(^[\s\/]+)|([\s\/]+$)/, '')
      controller = (options[:controller] || 'docusign/response')
      action = (options[:action] || 'index')
      get path, to: "#{controller}##{action}", as: :docusign_response
    end

  end
end
