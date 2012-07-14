class CreateUserAttachments < ActiveRecord::Migration
  def change
    create_table :user_attachments do |t|
      t.integer :user_profile_id
      t.string :attachment

      t.timestamps
    end
  end
end
