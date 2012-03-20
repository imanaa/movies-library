class Movie < ActiveRecord::Base
  belongs_to :location
  has_many :tags, :dependent => :destroy

  # Validation
  validates :title, :location, :folder_name, :presence => true
  validates :title, :folder_name, :uniqueness => true
  validates :rank, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10}
  validates :seen, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0}
  #FIXME: 1900 sould not be hardcoded
  validate :year, :numericality => { :only_integer => true, :greater_than => 1900}

  def movie_folder_exists?
    return (folder_name? and Location.movie_folder_exists?(self))
  end

  def poster_file_exists?
    return (poster? and Location.poster_file_exists?(self))
  end

  # parse the tags from a given string, convert them into new Tag objects, and associate them with the current model 
  def tags!(str)
    tags = str.split(",").map { |tag|
      Tag.find_or_create_by_value(tag.strip.downcase)
    }
    self.tags << tags
  end
end