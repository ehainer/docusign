Rails.application.routes.draw do

  allow_document_response

  root to: 'home#index'

end
