class UserAttachment < ActiveRecord::Base
  attr_accessible :attachment, :user_profile_id
  belongs_to :user_profile

  mount_uploader :attachment, AttachmentUploader
end
