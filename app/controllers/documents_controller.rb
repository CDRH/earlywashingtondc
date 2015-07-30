class DocumentsController < ApplicationController
  def index
	  _index_finder()
  end

  def dropdown
    qfield = ""
    qtext = ""
    if params.has_key?(:document)
      qfield = "subCategory"
      qtext = params[:document]
    elsif params.has_key?(:term)
      qfield = "term_ss"
      qtext = params[:term]
    elsif params.has_key?(:jurisdiction)
      qfield = "jurisdiction_ss"
      qtext = params[:jurisdiction]
    elsif params.has_key?(:places)
      qfield = "places"
      qtext = params[:places]
    end
    @docs = $solr.query({ :qfield => qfield, :qtext => qtext })
    @total_pages = (@docs[:num_found].to_f/50).ceil
    params[:qfield] = qfield
    params[:qtext] = qtext
    render :template => "documents/search"
  end

  def search
    # TODO so at this point, why not just use params instead of options?
    # reset fq to be all results not just actual documents
    options = { :qfield => params[:qfield], :qtext => params[:qtext], :fq => "*:*"}
    rows = 50 # this is the default
    if params.has_key?(:sort) && params[:sort].length > 0
      options[:sort] = "#{params[:sort]} asc"
    end
    if params.has_key?(:page) && params[:page].to_i > 0
      options[:page] = params[:page]
    end
    if params.has_key?(:rows)
      options[:rows] = params[:rows]
      rows = options[:rows].to_i
    end
    if params.has_key?(:fqtext) && params.has_key?(:fqfield)
      options[:fqfield] = params[:fqfield]
      options[:fqtext] = params[:fqtext]
    end
    # override filter query (fq) with facets
    # TODO is that a good idea?? q should always be search term
    # and fq would only be restricting by another criteria so this seems okay for now
    if params.has_key?(:facet)
      options[:fqfield] = "recordType_s"
      options[:fqtext] = params[:facet]
    end
    @docs = $solr.query(options)
    # TODO there is so much wrong with the following:
    # shouldn't specify facet = true, should be able to use qfield / qtext in gem
    facetq = "#{params[:qfield]}:\"#{params[:qtext]}\""
    facets = $solr.get_facets({:q => facetq, :facet => "true"}, ["recordType_s"])
    @categories = facets["recordType_s"]
    # default response is 50 pages, divide and round up for all
    @total_pages = (@docs[:num_found].to_f/rows).ceil
  end

  def show
    # if this is actually a person or a case, redirect
    @doc = $solr.get_item_by_id(params[:id])
    if @doc["recordType_s"] == "person"
      redirect_to person_path(params[:id])
    elsif @doc["recordType_s"] == "caseid"
      redirect_to case_path(params[:id])
    else
      url = @doc["uriHTML"]
      @res = Net::HTTP.get(URI.parse(url))
    end
  end
  
  def advancedsearch
    # get a list of all the people
    people_facets = $solr.get_facets({:q => "recordType_s:person", 
      :facet => "true", "facet.limit" => "-1",
      "facet.mincount" => "1"}, ["title"])
    @people = people_facets["title"].keys
  end

  def supplementary
    @docs = $solr.query({ :qfield => "category", :qtext => "Supplementary Documents" })
    # TODO could use index view with some minor tweaking
  end
end
