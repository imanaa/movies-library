class Movie < ActiveRecord::Base
  belongs_to :location
  validates :title, :location, :folder_name, :presence => true
  validates :title, :folder_name, :uniqueness => true
  validates :rank, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10}
  validates :seen, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0}
  #FIXME: 1900 sould not be hardcoded
  validate :year, :numericality => { :only_integer => true, :greater_than => 1900}
end