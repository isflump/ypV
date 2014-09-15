class Session < ActiveRecord::Base
  belongs_to :project
  has_many :executions
  has_many :tags

  validates :start_time, :end_time, presence: true
end
