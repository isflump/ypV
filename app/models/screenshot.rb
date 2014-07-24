class Screenshot < ActiveRecord::Base
  belongs_to :execution
  mount_uploader :avatar, SshotUploader
end
