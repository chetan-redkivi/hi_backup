class UserProfile < ActiveRecord::Base
  attr_accessible :description, :email, :fullname, :img_url, :zipcode, :user_id, :positions, :industries, :user_experiences, :user_positions, :user_industries, :user_attachments

  belongs_to :user
  has_many :user_attachments, :dependent => :destroy
  has_many :user_industries, :dependent => :destroy
  has_many :user_experiences, :dependent => :destroy
  has_many :user_positions, :dependent => :destroy

  has_many :positions, :through => :user_positions
  has_many :industries, :through => :user_industries
end
