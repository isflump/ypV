class Execution < ActiveRecord::Base
  before_save :default_values

  belongs_to :session
  has_many :screenshots

  def default_values
    self.isViewed ||= false
  end
end
