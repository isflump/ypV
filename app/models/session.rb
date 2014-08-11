class Session < ActiveRecord::Base
  belongs_to :project
  has_many :executions

  validates :start_time, :end_time, presence: true
end
