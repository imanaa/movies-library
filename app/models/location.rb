class Location < ActiveRecord::Base
  has_many :movies, :dependent => :destroy
  # TODO Note that some databases are configured to perform case-insensitive searches anyway.
  validates :path, :presence => true, :uniqueness => { :case_sensitive => false }
  # Scan all locations for movies
  def self.scan_all
    Location.all.each { |location|
      location.scan()
    }
  end

  # Scan this location for movies
  def scan
    #scan_folder()
    self.delay.scan_folder()
  end

  # Analyze all movie structures
  # TODO create the corresponding GUI
  require "csv"

  def self.analyze_all
    results = {}
    Location.all.each { |location|
      results.merge!(location.analyze())
    }
    CSV.open("D:/file.csv", "w:windows-1250") do |csv|
      results.each { |folder_name, stats|
        csv << [folder_name, stats[:movie_files], stats[:sub_folders]]
      }
    end
  end

  # Analyze the movie structures
  def analyze
    analyze_folder
  end

  # Is this locations reachable ?
  def reachable?
    Dir.exists?(path)
  end

  private

  def load_meta_data(movie_folder)
    yml = {}
    # look for any meta data
    _file = File.join(movie_folder, ".info.yml")

    Dir.chdir(path) {
      if File.exists?(_file)
        begin
        # FIXME yml variable should be a Hash Value
          yml = YAML.load_file(_file)
        rescue Exception => e
          warn e
        end
      end
    }

    yml[:title] = movie_folder.gsub("."," ") unless yml.key? :title
    yml[:seen] = 0 unless yml.key? :seen
    yml[:rank] = 0 unless yml.key? :rank
    yml[:tags] = "" unless yml.key? :tags
    yml[:folder_name] = movie_folder

    unless yml.key? :year
      # Guess the production year
      movie_year = movie_folder[/(20|19)\d{2}/]
      yml[:year] = movie_year.nil? ? nil : movie_year.to_i
    end

    return yml
  end

  # Look for movies in the folder
  def scan_folder
    movies.update_all(:online => false)
    return unless reachable?

    Dir.chdir(path) {
      movie_folders = Dir["*"].reject{ |o| not File.directory?(o) }
      movie_folders.each { |movie_folder|
        movie_folder = File.basename(movie_folder)
        movie = Movie.find_by_folder_name(movie_folder)

        if movie==nil then
          # New Movie or Existing one with Changed Folder Name ?
          _meta = load_meta_data(movie_folder)

          # Duplicated Movie Title ?
          movie = Movie.find_by_title(_meta[:title])
          if movie==nil then
            movie = Movie.new(:title => _meta[:title], :folder_name => _meta[:folder_name], :year => _meta[:year], :seen => _meta[:seen], :rank => _meta[:rank])
            movie.tags!(_meta[:tags])
          else
            movie.folder_name = movie_folder
          end
        end

        movie.location = self
        movie.online = true

        # Choose the first available movie poster
        unless movie.poster? and File.exists?(File.join(movie_folder, movie.poster)) then
          _posters = movie.available_posters
          movie.poster = (_posters.size>1)? File.basename(_posters[1]) : nil
        end
        movie.save
      }
    }
  end

  # Analyze folder structure
  def analyze_folder
    results = {}

    if reachable? then
      movies.each { |movie|
        folder_name = movie.folder_path
        next unless Dir.exists?(folder_name)

        Dir.chdir(folder_name) do |d|
          results[folder_name] = {
            :movie_files => (Dir['*.avi'] + Dir['*.mkv'] + Dir['*.vob']).size ,
            :sub_folders => Dir['*/'].size,
          }
        end
      }
    end

    return results
  end
end