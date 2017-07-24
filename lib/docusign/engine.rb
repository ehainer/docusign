module Docusign
  class Engine < Rails::Engine

    isolate_namespace Docusign

    initializer 'docusign.initialize' do
      ::ActiveRecord::Base.send :extend, ::Docusign::ActiveRecord
      ::ActionController::Base.send :helper, ::Docusign::DocumentHelper
      ::ActionDispatch::Routing::Mapper.send :include, ::Docusign::Routes
    end

  end
end
