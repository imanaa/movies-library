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

  def pretty_title
    return title.size>40 ? "#{title.to_s[0..40]} ..." : title
  end

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