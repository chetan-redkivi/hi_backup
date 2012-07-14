class UserIndustry < ActiveRecord::Base
  attr_accessible :industry_id, :user_profile_id
  belongs_to :user_profile
  belongs_to :industry
end
