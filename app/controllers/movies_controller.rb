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

    _success = @movie.update_attributes(params[:movie])
    @movie.poster = Location.poster_files(@movie)[params[:poster_index].to_i-1].to_s
    _success &= @movie.save

    if _success then
      flash[:notice] = "Movie was successfully updated."
    else
      flash[:error] = @movie.errors.full_messages.to_sentence
    end

    respond_to do |format|
      format.html { redirect_to edit_movie_path, :status => 303, :flash => flash }
    end
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    redirect_to :root
  end

  def search
    year = [ params[:year_1].to_i, params[:year_2].to_i ]
    year = (year.min)..(year.max)
    rank = [ params[:rank_1].to_i, params[:rank_2].to_i ]
    rank = (rank.min)..(rank.max)
    seen = [ params[:seen_1].to_i, params[:seen_2].to_i ]
    seen = (seen.min)..(seen.max)

    @search = Movie.search do
      all_of do
        with(:online, false) unless params[:offline].nil?
        with(:online, true) unless params[:online].nil?
        with(:year, year) unless (params[:year_1].to_s.empty?) or (params[:year_2].to_s.empty?)
        with(:rank, rank) unless (params[:rank_1].to_s.empty?) or (params[:rank_2].to_s.empty?)
        with(:seen, seen) unless (params[:seen_1].to_s.empty?) or (params[:seen_2].to_s.empty?)
      end
      keywords params[:q] unless params[:q].nil?
      paginate :page => params[:page], :per_page => 10
    end
    @movies = @search.results

    respond_to do |format|
      format.html { }
    end
  end
end