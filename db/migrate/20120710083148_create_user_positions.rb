class CreateUserPositions < ActiveRecord::Migration
  def change
    create_table :user_positions do |t|
      t.integer :user_profile_id
      t.integer :position_id

      t.timestamps
    end
  end
end
