module Docusign
  module DocumentHelper

    include ::ActionView::Helpers::TagHelper

    def embedded_document(envelope, recipient=nil, **html_options)
      html_options.merge!(src: envelope.url(recipient))
      content_tag :iframe, nil, html_options
    end

  end
end
