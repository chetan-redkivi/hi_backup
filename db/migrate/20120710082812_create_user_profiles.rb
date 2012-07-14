class CreateUserProfiles < ActiveRecord::Migration
  def change
    create_table :user_profiles do |t|
      t.string :fullname
      t.string :email
      t.integer :zipcode
      t.string :img_url
      t.string :description
      t.integer :user_id
      t.timestamps
    end
  end
end
