class CreateDocusignTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :docusign_templates do |t|
      t.string :template_id
      t.string :email_subject
      t.string :description
      t.string :name
      t.text :email_blurb
      t.string :documents
      t.references :templatable, polymorphic: true, index: { name: 'index_docusign_templates_on_templatable_type_and_id' }
    end

    add_index :docusign_templates, :template_id, unique: true
  end
end
