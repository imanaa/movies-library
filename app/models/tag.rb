class Tag < ActiveRecord::Base
  belongs_to :movie
  
  validates :value, :presence => true, :uniqueness => { :scope => :movie_id, :case_sensitive => false } 
end
