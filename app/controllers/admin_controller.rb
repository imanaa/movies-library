class AdminController < ApplicationController
  def index
  end

  def delete_offline
    Movie.where(:online => false).destroy_all
    respond_to { |format|
      format.html { redirect_to({:controller => "admin", :action => "index"}, :notice => "Offline Movies Removed" ) }
    }
  end
end
