require 'fileutils'

class MovieObserver < ActiveRecord::Observer
  # Make sure to create / update the movie poster
  def after_save(movie)
    if movie.poster_changed? or ! File.exists?(movie.cached_poster) then
      movie.logger.info("** Update File : #{movie.cached_poster}")
      if movie.poster.nil? then
        FileUtils.cp Movie.empty_poster, movie.cached_poster
      else
        poster = File.join(movie.location.path, movie.folder_name, movie.poster)
        FileUtils.cp poster, movie.cached_poster
      end
    end
  end

  # Make sure to remove the cached poster
  def after_destroy(movie)
    movie.logger.info("** Remove File : #{movie.cached_poster}")
    FileUtils.remove_file(movie.cached_poster, true)
  end
end