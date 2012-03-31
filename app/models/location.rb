class Location < ActiveRecord::Base
  has_many :movies, :dependent => :destroy
  #TODO: Note that some databases are configured to perform case-insensitive searches anyway.
  validates :path, :presence => true, :uniqueness => { :case_sensitive => false }

  # Scan all locations for movies
  def Location.scan_all
    Location.all.each { |location|
      location.scan()
    }
  end

  # Scan this location for movies
  def scan
    self.delay.scan_folder()
    #scan_folder()
  end

  # Is this locations reachable ?
  def reachable?
    Dir.exists?(path)
  end

  private

  # Look for movies in the folder
  def scan_folder
    movies.update_all(:online => false)
    return unless reachable?
    Dir.chdir(path) {
      Dir['*/'].each { |movie_folder|
        movie_folder = File.basename(movie_folder)
        movie = Movie.find_by_folder_name(movie_folder)
        if movie==nil then
          movie = Movie.new(:title => movie_folder.gsub("."," "), :folder_name => movie_folder)
          # Guess the production year
          movie_year = movie_folder[/(20|19)\d{2}/]
          movie.year = movie_year.nil? ? nil : movie_year.to_i
        end
        movie.location = self
        movie.online = true
        # Choose the first available movie poster
        unless movie.poster? and File.exists?( File.join(movie_folder, movie.poster)) then
          _posters = movie.available_posters
          movie.poster = (_posters.size>1)? File.basename(_posters[1]) : nil
        end
        movie.save
      }
    }
  end
end