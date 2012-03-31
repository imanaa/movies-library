class LocationsController < ApplicationController
  # List all locations
  def index
    @locations = Location.order(:path).all
    @location  = Location.new()
  end

  # Create a new Location
  def create
    @location = Location.new(params[:location])

    if Dir.exists?(@location.path.to_s) then
      #The follwing line is to ease redundancy checking
      @location.path = File.absolute_path(@location.path)
      if @location.save then
        flash[:notice] = "Successfully Created"
      else
        flash[:error] = @location.errors.empty? ? "Error" : @location.errors.full_messages.to_sentence
      end
    else
      flash[:error] = "Folder does not exists"
    end

    respond_to { |format|
      format.html { redirect_to :action => "index", :method => "get", :status=> 303 }
    }
  end

  # Remove a location and all its movies
  def destroy
    Location.destroy(params[:id])
    flash[:notice] = "Successfully Deleted"
    respond_to { |format|
      format.html { redirect_to :action => "index", :method => "get", :status=> 303 }
    }
  end

  # Scan the selected location
  def scan
    @location = Location.find(params[:id])
    @location.scan
    respond_to { |format|
      format.html { redirect_to({:controller => "admin", :action => "index", :methods => :get, :status=> 303}, :notice => "Scan Launched" ) }
    }
  end

  # Scan all locations
  def scan_all
    Location.scan_all
    respond_to { |format|
      format.html { redirect_to({:controller => "admin", :action => "index", :methods => :get, :status=> 303}, :notice => "Scan Launched" ) }
    }
  end
end