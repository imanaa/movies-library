class MoviesController < ApplicationController
  # Number of movies per page
  PER_PAGE = 10
  # Listing all movies
  def index
    @movies = Movie.order(:title).page(params[:page]).per(PER_PAGE)
    respond_to do |format|
      format.html { }
    end
  end

  # if index < 0; renders the cached poster
  # if index = 0; renders the empty poster
  # if index > 0, renders the corresponding poster if exists
  def poster
    @movie = Movie.find(params[:id])
    index = params[:index].to_i

    filename = ""
    options = { :disposition => 'inline', :url_based_filename => true }

    if index < 0 then
      filename = @movie.cached_poster
      options[:type] = @movie.poster? ? @movie.poster : Movie.empty_poster
    else
      filename = @movie.available_posters[index]
      filename = Movie.empty_poster if filename.nil?
      options[:type] = filename
    end
    options[:type] = MIME::Types.type_for(options[:type]).first.content_type

    #FIXME: On firefox it shows image corrupt or truncated
    send_file filename, options
  end

  # Edit the movie
  def edit
    @movie = Movie.find(params[:id])
    # For the poster selection
    @poster_files = @movie.available_posters
    @poster_index = @poster_files.index(@movie.poster_path).to_i
    # For the new tag form
    @new_tag = Tag.new
    @new_tag.movie = @movie

    respond_to do |format|
      format.html { render "edit.html.erb" }
    end
  end

  # Update the movie
  def update
    @movie = Movie.find(params[:id])

    # update the record
    _success = @movie.update_attributes(params[:movie])

    # update the poster
    unless params[:poster_index].nil? then
      poster_index = params[:poster_index].to_i
      if poster_index <= 0 then
        @movie.poster = nil
      else
        _poster = @movie.available_posters[poster_index]
        @movie.poster = _poster.nil? ? nil : File.basename(_poster)
      end
      _success &= @movie.save
    end

    if _success then
      flash[:notice] = "Movie was successfully updated."
    else
      flash[:error] = @movie.errors.full_messages.to_sentence
    end

    respond_to do |format|
      format.html { redirect_to edit_movie_path, :status => 303, :flash => flash }
    end
  end

  # Remove the movie
  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy

    respond_to do |format|
      format.html { redirect_to :root }
    end

  end

  # shows a random movie
  def random
    @movies = Movie.all
    unless @movies.nil? then
      @movie = @movies[rand(@movies.size)]
      params[:id] = @movie.id
      edit()
      return
    end

    respond_to do |format|
      format.html { redirect_to :root }
    end
  end

  # Search movies
  def search
    #FIXME: unstead of year_1 and year_2 we should receive an array
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
      paginate :page => params[:page], :per_page => PER_PAGE
    end
    @movies = @search.results

    respond_to do |format|
      format.html { }
    end
  end
end