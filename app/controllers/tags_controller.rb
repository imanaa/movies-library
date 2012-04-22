class TagsController < ApplicationController
  # Tag Cloud
  def index
    @histogram = Tag.to_histogram
  end
  
  # Create new tags for the movie
  def create
    @movie = Movie.find(params[:movie_id])
    @movie.tags!(params[:tag][:value])
    respond_to { |format|
      format.html { redirect_to edit_movie_path(@movie), :flash => { :notice => "Successfully Tagged!"} }
    }
  end

  # Remove a tag
  def destroy
    @movie = Movie.find(params[:movie_id])
    @tag = Tag.find(params[:id])
    @movie.tags.destroy(@tag)
    respond_to { |format|
      format.html { redirect_to edit_movie_path(@movie), :flash => { :notice => "Successfully Removed!"} }
    }
  end
end