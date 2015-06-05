class DocumentsController < ApplicationController
  def index
    @all_docs = @@solr.query
  end

  def dropdown
    qfield = ""
    qtext = ""
    if params.has_key?(:document)
      qfield = "subCategory"
      qtext = params[:document]
    else params.has_key?(:term)
      qfield = "term_ss"
      qtext = params[:term]
    # else if attorneys
    end
    @docs = @@solr.query({ :qfield => qfield, :qtext => qtext })
    @total_pages = (@docs[:num_found].to_f/50).ceil
    params[:qfield] = qfield
    params[:qtext] = qtext
    render :template => "documents/search"
  end

  def search
    options = { :qfield => params[:qfield], :qtext => params[:qtext]}
    if params.has_key?(:sort) && params[:sort].length > 0
      options[:sort] = "#{params[:sort]} asc"
    end
    if params.has_key?(:page) && params[:page].to_i > 0
      options[:page] = params[:page]
    end
    @docs = @@solr.query(options)
    # default response is 50 pages, divide and round up for all
    @total_pages = (@docs[:num_found].to_f/50).ceil
  end

  def show
    @doc = @@solr.get_item_by_id(params[:id])
    url = @doc["uriHTML"]
    @res = Net::HTTP.get(URI.parse(url))
  end

  def supplementary
    @docs = @@solr.query({ :qfield => "category", :qtext => "Supplementary Documents" })
    # TODO could use index view with some minor tweaking
  end
end
