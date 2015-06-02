class DocumentsController < ApplicationController
  def index
    @all_docs = @@solr.query
  end

  def dropdown
    qfield = ""
    qtext = ""
    if params.has_key?(:document)
      qfield = "subtype"
      qtext = params[:document]
    else params.has_key?(:term)
      qfield = "term"
      qtext = params[:term]
    # else if attorneys
    end
    @docs = @@solr.query({ :qfield => qfield, :qtext => qtext })
    params[:qfield] = qfield
    params[:qtext] = qtext
    render :template => "documents/search"
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
