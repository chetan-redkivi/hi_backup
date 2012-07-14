class UserProfile < ActiveRecord::Base
  attr_accessible :description, :email, :fullname, :img_url, :zipcode, :user_id

  belongs_to :user
  has_many :user_attachments, :dependent => :destroy
  has_many :user_industries, :dependent => :destroy
  has_many :user_experiences, :dependent => :destroy
  has_many :user_positions, :dependent => :destroy
end
