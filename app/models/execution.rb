class Execution < ActiveRecord::Base

  belongs_to :session
  has_many :screenshots

  # before_save :prepare_save
  # def prepare_save
  #   self.isViewed = false
  # end
end
