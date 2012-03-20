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
    #FIXME: On firefox it shows image corrupt or truncated
    send_file filename, :type => content_type, :disposition => 'inline'
  end

  def edit
    @movie = Movie.find(params[:id])
    @tag = Tag.new
    @tag.movie = @movie
  end

  def update
    @movie = Movie.find(params[:id])
    #FIXME: Does this override the flash value
    flash  = {}
    if @movie.update_attributes(params[:movie]) then
      flash[:notice] = "Movie was successfully updated."
    else
      flash[:error] = @movie.errors.full_messages.to_sentence
    end
    respond_to do |format|
      if (params[:source_form].to_i==2) then
        format.html { redirect_to edit_movie_path, :flash => flash }
      else
        format.html { redirect_to( {:action => "index", :page => params[:page]}, :flash => flash ) }
      end
    end
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    redirect_to :root
  end
end