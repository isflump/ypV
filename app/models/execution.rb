class Execution < ActiveRecord::Base
  belongs_to :session
  has_many :screenshots
end
