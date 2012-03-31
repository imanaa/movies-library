class AdminController < ApplicationController
  # Main Page
  def index
  end

  # Remove all offline movies
  def delete_offline
    Movie.where(:online => false).destroy_all
    respond_to { |format|
      format.html { redirect_to({:controller => "admin", :action => "index", :status=> 303}, :notice => "Offline Movies Removed" ) }
    }
  end

  # Reindex Movies - for searching via solr
  def reindex
    Movie.delay.reindex
    #Movie.reindex
    respond_to { |format|
      format.html { redirect_to({:controller => "admin", :action => "index", :status=> 303}, :notice => "Reindexation Launched ! " ) }
    }
  end
end