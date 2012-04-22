class Tag < ActiveRecord::Base
  belongs_to :movie

  validates :value, :presence => true, :uniqueness => { :scope => :movie_id, :case_sensitive => false }

  def self.to_histogram(max_entries=100)
    _tags = Tag.select('value, COUNT(value) as nb').group(:value).order('nb desc').limit(max_entries).all
    Hash[*_tags.collect { |_tag|
      [ _tag.value, _tag.nb ]
    }.flatten]
  end
end
