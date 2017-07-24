class User < ApplicationRecord

  documentable

  def to_signer
    {
      name: name,
      email: email,
      embedded: true,
      role_name: 'Signer'
    }
  end

end
