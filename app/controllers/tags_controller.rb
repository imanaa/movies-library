class TagsController < ApplicationController
  def create
    logger.error "******************************************************IMAD"
    logger.error params.to_s
    @movie = Movie.find(params[:movie_id])
    tags   = params[:tag][:value].strip
    @movie.tags!(tags)
    respond_to { |format|
      format.html { redirect_to edit_movie_path(@movie), :flash => { :notice => "Successfully Tagged!"} }
    }
  end

  def destroy
  end
end
