class DocumentsController < ApplicationController
  def index
    @all_docs = @@solr.query
  end

  def search
    options = { :qfield => params[:qfield], :qtext => params[:qtext]}
    if params.has_key?(:sort) && params[:sort].length > 0
      options[:sort] = "#{params[:sort]} asc"
    end
    @docs = @@solr.query(options)
  end

  def show
    @doc = @@solr.get_item_by_id(params[:id])
  end

  def supplementary
    @docs = @@solr.query({ :qfield => "type", :qtext => "Supplementary Documents" })
    # TODO could use index view with some minor tweaking
  end
end
