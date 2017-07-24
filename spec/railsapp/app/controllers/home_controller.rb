class HomeController < ApplicationController

  def index
    User.last.envelopes.create!(email_subject: Faker::Name.title, status: :sent) do |d|
      d.add_document '/web/RedDot/spec/fixtures/files/pdf1.pdf'
      d.add_signer do
        sign_at 'Known Issues', 0, 100
      end
    end
  end

end
