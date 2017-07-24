module Docusign
  module DocumentHelper

    include ::ActionView::Helpers::TagHelper

    def embedded_document(envelope, name=nil, email=nil, **html_options)
      html_options.merge!(src: envelope.url(name, email))
      content_tag :iframe, nil, html_options
    end

  end
end
