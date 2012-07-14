class UserPosition < ActiveRecord::Base
  attr_accessible :position_id, :user_profile_id
  belongs_to :user_profile
  belongs_to :position
end
