class LocationsController < ApplicationController
  def index
    @locations = Location.order(:path).all
    @location  = Location.new()
  end

  def create
    @location = Location.new(params[:location])
    unless Dir.exists?(@location.path.to_s)
      flash[:error] = "Folder does not exists"
    else
      #To check for possible redundance
      @location.path = File.expand_path(@location.path)
      if @location.save then
        flash[:notice] = "Successfully Created"
      else
        flash[:error] = @location.errors.empty? ? "Error" : @location.errors.full_messages.to_sentence
      end
    end

    redirect_to locations_path
  end

  def destroy
    Location.destroy(params[:id])
    flash[:notice] = "Successfully Deleted"
    redirect_to :action => "index", :method => "get"
  end

  def scan_all
    Location.scan_all
  end
end