module Docusign
  module Generators
    class InstallGenerator < Rails::Generators::Base

      source_root File.expand_path('../../../../', __FILE__)

      desc 'Install Docusign'

      def copy_views
        copy_file 'app/views/docusign/response/index.html.erb', Rails.root.join('app', 'views', 'docusign', 'response', 'index.html.erb')
        copy_file 'app/views/docusign/response/codes/_access_code_failed.html.erb', Rails.root.join('app', 'views', 'docusign', 'response', 'codes', '_access_code_failed.html.erb')
        copy_file 'app/views/docusign/response/codes/_cancel.html.erb', Rails.root.join('app', 'views', 'docusign', 'response', 'codes', '_cancel.html.erb')
        copy_file 'app/views/docusign/response/codes/_decline.html.erb', Rails.root.join('app', 'views', 'docusign', 'response', 'codes', '_decline.html.erb')
        copy_file 'app/views/docusign/response/codes/_disallowed.html.erb', Rails.root.join('app', 'views', 'docusign', 'response', 'codes', '_disallowed.html.erb')
        copy_file 'app/views/docusign/response/codes/_exception.html.erb', Rails.root.join('app', 'views', 'docusign', 'response', 'codes', '_exception.html.erb')
        copy_file 'app/views/docusign/response/codes/_fax_pending.html.erb', Rails.root.join('app', 'views', 'docusign', 'response', 'codes', '_fax_pending.html.erb')
        copy_file 'app/views/docusign/response/codes/_id_check_failed.html.erb', Rails.root.join('app', 'views', 'docusign', 'response', 'codes', '_id_check_failed.html.erb')
        copy_file 'app/views/docusign/response/codes/_session_timeout.html.erb', Rails.root.join('app', 'views', 'docusign', 'response', 'codes', '_session_timeout.html.erb')
        copy_file 'app/views/docusign/response/codes/_signing_complete.html.erb', Rails.root.join('app', 'views', 'docusign', 'response', 'codes', '_signing_complete.html.erb')
        copy_file 'app/views/docusign/response/codes/_ttl_expired.html.erb', Rails.root.join('app', 'views', 'docusign', 'response', 'codes', '_ttl_expired.html.erb')
        copy_file 'app/views/docusign/response/codes/_viewing_complete.html.erb', Rails.root.join('app', 'views', 'docusign', 'response', 'codes', '_viewing_complete.html.erb')
      end

      def copy_uploader
        copy_file 'app/uploaders/docusign/document_uploader.rb', Rails.root.join('app', 'uploaders', 'docusign', 'document_uploader.rb')
      end

      def copy_controllers
        copy_file 'app/controllers/docusign/response_controller.rb', Rails.root.join('app', 'controllers', 'docusign', 'response_controller.rb')
      end

      def copy_initializer
        create_file Rails.root.join('config', 'initializers', 'docusign.rb'), <<-CONTENT
Docusign.setup do |config|

  # Docusign username
  config.username = ''

  # Docusign password
  config.password = ''

  # Docusign integrator key
  config.key = ''

  # Docusign account id
  config.account_id = ''

  # Docusign api endpoint url. If not in production, use `https://demo.docusign.net/restapi`
  config.endpoint = 'https://www.docusign.net/restapi'

  # The Docusign "tabs" that can be generated. This list defines the tab methods `<tab_name>_at`
  # For a full list of possible tabs, see https://docs.docusign.com/esign/restapi/Envelopes/Envelopes/create/#/definitions/EnvelopeRecipientTabs
  # config.tabs = [:approve, :checkbox, :company, :date_signed, :date, :decline, :email_address, :email, :envelope_id, :first_name, :formula, :full_name, :initial_here, :last_name, :list, :note, :number, :radio_group, :signer_attachment, :sign_here, :ssn, :text, :title, :view, :zip]

end
CONTENT
      end

      def copy_migrations
        copy_migration 'create_docusign_envelopes'
        copy_migration 'create_docusign_templates'
        copy_migration 'create_docusign_signers'
      end

      protected

        def copy_migration(filename)
          if migration_exists?(Rails.root.join('db', 'migrate'), filename)
            say_status('skipped', "Migration #{filename}.rb already exists")
          else
            copy_file "db/migrate/#{filename}.rb", Rails.root.join('db', 'migrate', "#{migration_number}_#{filename}.rb")
          end
        end

        def migration_exists?(dirname, filename)
          Dir.glob("#{dirname}/[0-9]*_*.rb").grep(/\d+_#{filename}.rb$/).first
        end

        def migration_id_exists?(dirname, id)
          Dir.glob("#{dirname}/#{id}*").length > 0
        end

        def migration_number
          @migration_number ||= Time.now.strftime("%Y%m%d%H%M%S").to_i

          while migration_id_exists?(Rails.root.join('db', 'migrate'), @migration_number) do
            @migration_number += 1
          end

          @migration_number
        end

    end
  end
end
