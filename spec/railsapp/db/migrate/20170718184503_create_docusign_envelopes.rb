class CreateDocusignEnvelopes < ActiveRecord::Migration[5.1]
  def change
    create_table :docusign_envelopes do |t|
      t.string :envelope_id
      t.integer :template_id
      t.string :email_subject
      t.text :email_blurb
      t.integer :status, default: 0
      t.string :documents
      t.references :envelopable, polymorphic: true, index: { name: 'index_docusign_envelopes_on_envelopable_type_and_id' }
    end

    add_index :docusign_envelopes, :envelope_id, unique: true
  end
end
