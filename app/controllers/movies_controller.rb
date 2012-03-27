class MoviesController < ApplicationController
  def index
    @movies = Movie.order(:title).page(params[:page]).per(10)
    respond_to do |format|
      format.html { }
    end
  end

  def poster
    @movie = Movie.find(params[:id])
    index = params[:index].to_i
    filename = _default = File.join(Rails.root, 'app', "assets", "images", "img01.gif")

    if index != 0 then
      if index == -1 then
        _element = @movie.poster
      else
        _element = Location.poster_files(@movie)[index-1].to_s.strip()
      end
      filename = File.join(@movie.location.path, @movie.folder_name, _element) unless _element==""

      if !File.exists?(filename) or File.directory?(filename) then
        filename = _default
      end
    end

    content_type = MIME::Types.type_for(filename).first.content_type
    #FIXME: On firefox it shows image corrupt or truncated
    send_file filename, :type => content_type, :disposition => 'inline', :url_based_filename => true
  end

  def edit
    @movie = Movie.find(params[:id])
    @poster_files = Location.poster_files(@movie).unshift("")
    @poster_index = @poster_files.index(@movie.poster.to_s).to_i
    # For the new tag form
    @new_tag = Tag.new
    @new_tag.movie = @movie
  end

  def update
    @movie = Movie.find(params[:id])
    #FIXME: Does this override the flash value
    flash  = {}

    _success = @movie.update_attributes(params[:movie])
    @movie.poster = Location.poster_files(@movie)[params[:poster_index].to_i-1].to_s
    @movie.save!

    if _success then
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