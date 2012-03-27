class TagsController < ApplicationController
  def create
    @movie = Movie.find(params[:movie_id])
    tags   = params[:tag][:value].strip
    @movie.tags!(tags)
    respond_to { |format|
      format.html { redirect_to edit_movie_path(@movie), :flash => { :notice => "Successfully Tagged!"} }
    }
  end

  def destroy
    @movie = Movie.find(params[:movie_id])
    @tag = Tag.find(params[:id])
    @movie.tags.delete(@tag)
    respond_to { |format|
      format.html { redirect_to edit_movie_path(@movie), :flash => { :notice => "Successfully Removed!"} }
    }
  end
end
