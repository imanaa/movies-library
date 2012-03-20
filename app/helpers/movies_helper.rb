module MoviesHelper
  def poster_url(movie)
    path = image_path('img01.gif')
    return path unless movie.poster_file_exists?
    return url_for(:action => 'poster', :id => movie.id, :format => File.extname(movie.poster).delete(".").downcase)
  end
end