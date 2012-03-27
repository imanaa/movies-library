module MoviesHelper
  def poster_url(movie, index=-1)
    _url = {:action => 'poster', :id => movie.id, :index => index}
    if index == -1 then
      _url[:index] = Location.poster_files(movie).index(movie.poster)
      _url[:index] = (_url[:index] == nil)? 0 : _url[:index]+1
    end
    return url_for(_url)
  end
end