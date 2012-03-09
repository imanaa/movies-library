class MoviesController < ApplicationController
  def index
    @movies = Movie.order(:title).page(params[:page]).per(10)
    respond_to do |format|
      format.html { }
    end
  end

  def poster
    @movie = Movie.find(params[:id])
    File.open(File.join(@movie.location.path, @movie.folder_name, @movie.poster), "rb") { |file|
      image = file.read.to_blob
      render :layout => false, :text => image
    }
    return

    if File.exists?(movie.poster_path) then
      content_type = MIME::Types.type_for(movie.poster_path).first.content_type
      file = File.open(movie.poster_path,"rb")
      image = file.read.to_blob
      file.close
      render  :layout => false, :text => image
    end
  end
end
