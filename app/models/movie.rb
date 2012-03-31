class Movie < ActiveRecord::Base
  belongs_to :location
  has_many :tags, :dependent => :destroy

  # Full Test Search with sunspot
  searchable do
    text :title
    text :tags do
      tags.map { |tag| tag.value }
    end
    integer  :rank
    integer  :seen
    integer  :year
    boolean  :online
  end

  # Validation
  def self.range(attribute)
    return case attribute
    when :year then 1900..2100
    when :rank then 0..10
    when :seen then 0..9999
    else nil
    end
  end

  validates :title, :location, :folder_name, :presence => true
  validates :title, :folder_name, :uniqueness => true
  validates :rank, :numericality => { :only_integer => true, :greater_than_or_equal_to => range(:rank).min, :less_than_or_equal_to => range(:rank).max }
  validates :seen, :numericality => { :only_integer => true, :greater_than_or_equal_to => range(:seen).min,  :less_than_or_equal_to => range(:seen).max }
  validates :year, :numericality => { :only_integer => true, :greater_than_or_equal_to => range(:year).min, :less_than_or_equal_to => range(:year).max }, :allow_nil => true

  # Return the full path of the empty poster
  def self.empty_poster
    File.join(Rails.root, "app", "assets", "images", "img01.gif")
  end

  # Return a pretty for of the title
  def pretty_title
    return title.size>40 ? "#{title.to_s[0..40]} ..." : title
  end

  # Parse the tags from a given string, convert them into new Tag objects, and associate them with the current model
  def tags!(str)
    str.strip!
    tags = str.split(",").map { |tag|
      Tag.find_or_create_by_value(tag.strip.downcase)
    }
    self.tags << tags
  end

  # Return the full path of the cached movie poster
  def cached_poster
    File.join(Rails.root,"posters",Rails.env,"img#{id}.jpg")
  end

  # Return the movie folder full path
  def folder_path
    File.join(location.path, folder_name)
  end
  
  # The poster full path
  def poster_path
    return nil unless poster? 
    return File.join folder_path, poster
  end

  # Is the movie folder reachable ?
  def folder_reachable?
    Dir.exists? folder_path
  end

  # If the movie folder is reachable, return an array of available posters; The empty string is the first element of this array
  # Otherwise an array containing the cached poster
  def available_posters
    return [cached_poster] unless folder_reachable?
    Dir.chdir(folder_path) {
      posters = Dir['*.{jpg,jpeg,png,gif}'].sort().map! { |_filename| File.join(folder_path, _filename) }
      return posters.unshift(Movie.empty_poster)
    }
  end
end