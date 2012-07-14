class CreateUserExperiences < ActiveRecord::Migration
  def change
    create_table :user_experiences do |t|
      t.integer :user_profile_id
      t.integer :department_id

      t.timestamps
    end
  end
end
