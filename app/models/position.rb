class Position < ActiveRecord::Base
  attr_accessible :title
  has_many :user_positions
end
