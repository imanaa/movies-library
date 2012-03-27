class Location < ActiveRecord::Base
  has_many :movies, :dependent => :destroy
  #TODO: Note that some databases are configured to perform case-insensitive searches anyway.
  validates :path, :presence => true, :uniqueness => { :case_sensitive => false }

  def Location.scan_all
    Location.all.each { |location|
      location.scan()
    }
  end

  def scan
    self.delay.scan_folder()
    #scan_folder()
  end

  # Does this locations exists ?
  def exists?
    Dir.exists?(path)
  end

  # Does the movie exists inside this location ?
  def Location.movie_folder_exists?(movie)
    Dir.exists?(File.join(movie.location.path, movie.folder_name))
  end

  # Does the movie exists inside this location ?
  def Location.poster_file_exists?(movie)
    File.exists?(File.join(movie.location.path, movie.folder_name, movie.poster))
  end

  # Returns an array of possible poster files
  def Location.poster_files(movie)
    _directory = File.join(movie.location.path, movie.folder_name)
    return [] unless Dir.exists?(_directory)
    Dir.chdir(_directory ) {
      return Dir['*.{jpg,jpeg,png,gif}'].sort()
    }
  end

  private

  def scan_folder
    movies.update_all(:online => false)
    return unless Dir.exists?(path)
    Dir.chdir(path) {
      Dir['*/'].each { |movie_folder|
        movie_folder = File.basename(movie_folder)
        movie = Movie.find_by_folder_name(movie_folder)
        if movie==nil then
          movie = Movie.new(:title => movie_folder, :folder_name => movie_folder)
          # Guess the production year
          movie_year = movie_folder[/(20|19)\d{2}/]
          #FIXME: 1900 sould not be hardcoded
          movie.year = movie_year.nil? ? 1900 : movie_year.to_i
        end
        movie.location = self
        movie.online = true
        # Choose a random movie poster
        unless movie.poster_file_exists? then
          posters = Location.poster_files(movie)
          movie.poster = posters.empty? ? nil : posters.first
        end
        movie.save
      }
    }
  end
end