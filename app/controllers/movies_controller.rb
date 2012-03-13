class MoviesController < ApplicationController
  def index
    @movies = Movie.order(:title).page(params[:page]).per(10)
    respond_to do |format|
      format.html { }
    end
  end

  def poster
    @movie = Movie.find(params[:id])
    filename = File.join(@movie.location.path, @movie.folder_name, @movie.poster)
    filename = File.join(Rails.root, 'app', "assets", "images", "img01.gif") unless File.exists?(filename)
    content_type = MIME::Types.type_for(filename).first.content_type
    send_file filename, :type => content_type, :disposition => 'inline'
  end
end
