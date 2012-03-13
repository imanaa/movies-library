class Location < ActiveRecord::Base
  has_many :movies, :dependent => :destroy
  #TODO: Note that some databases are configured to perform case-insensitive searches anyway.
  validates :path, :presence => true, :uniqueness => { :case_sensitive => false }

  def self.scan_all
    Movie.update_all(:online => 0)
    Location.all.each { |location|
      location.scan if Dir.exists?(location.path)
    }
  end

  def scan()
    self.delay.scan_folder()
  end

  private

  def scan_folder
    Dir.chdir(self.path) {
      Dir['*/'].each { |movie_folder|
        movie_folder.delete!("/")
        movie = Movie.find_by_folder_name(movie_folder)
        if movie==nil then
          Dir.chdir(movie_folder) {
            # Find a random poster image
            images = Dir['*.{jpg,jpeg,png,gif}']
            movie_poster = images.empty? ? nil : images.first
            # Guess the production year
            movie_year = movie_folder[/(20|19)\d{2}/]
            movie_year = 1900 if movie_year == nil
            movie = self.movies.create(:title=>movie_folder, :folder_name=>movie_folder, :online=>true, :poster=>movie_poster, :year=>movie_year)
          }
        else
          # Update the location if needed
          movie.location = self
          movie.online = true
          #FIXME: update the poster if not already set
          movie.save
        end
      }
    }
  end
end
