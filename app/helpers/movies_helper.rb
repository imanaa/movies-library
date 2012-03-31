module MoviesHelper
  # Generates the url of a movie poster
  # See movies#poster action for the meaning of index
  def poster_url(movie, index=-1)
    return url_for({:action => 'poster', :id => movie.id, :index => index})
  end
end