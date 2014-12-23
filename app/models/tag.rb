class Tag < ActiveRecord::Base
  belongs_to :session
  validates_uniqueness_of :name, scope: :session_id
end
