class UserExperience < ActiveRecord::Base
  attr_accessible :department, :user_profile, :exp_in_yrs
  belongs_to :user_profile
  belongs_to :department
end
