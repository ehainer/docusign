class CreateDocusignSigners < ActiveRecord::Migration[5.1]
  def change
    create_table :docusign_signers do |t|
      t.boolean :embedded, default: true
      t.string :name
      t.string :email
      t.string :role_name, default: 'Issuer'
      t.string :recipient_id
      t.integer :routing_order
      t.text :tabs
      t.references :signable, polymorphic: true
    end
  end
end
