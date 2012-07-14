class UserExperience < ActiveRecord::Base
  attr_accessible :department_id, :user_profile_id
  belongs_to :user_profile
  belongs_to :department
end
