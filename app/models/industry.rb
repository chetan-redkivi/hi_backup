class Industry < ActiveRecord::Base
  attr_accessible :title
  has_many :user_industries
end
