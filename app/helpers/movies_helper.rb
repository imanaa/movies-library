module MoviesHelper
  def poster_url(movie)
    path = image_path('img01.gif')
    return path if ( (movie.poster == "") || (movie.poster == nil) )
    return path unless File.exists?(File.join(movie.location.path, movie.folder_name, movie.poster))
    return url_for(:action => 'poster', :id => movie.id, :format => File.extname(movie.poster).delete("."))
  end
  
  def year_to_s(movie)
    #FIXME: 1900 sould not be hardcoded
    (movie.year==1900)? "N/A" : movie.year.to_s
  end
end