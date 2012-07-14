class AddYearsToUserExperiences < ActiveRecord::Migration
  def change
    add_column :user_experiences, :exp_in_yrs, :integer
  end
end
