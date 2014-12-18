class Jira < ActiveRecord::Base
	validates_uniqueness_of :case_name
end
