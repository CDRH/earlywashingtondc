class PeopleController < ApplicationController
	
  def index
  end
		
		
  def all
    if params[:letter]
      _index_finder({:fq => "recordType_s:person", :q => "titleLetter_s:#{params[:letter]}"})
    else
      _index_finder({:fq => "recordType_s:person"})
    end
    # TODO this isn't right, the gem shouldn't need "facet = true" so I'm not sure what's going on
    # it already has facet = true as a default in the gem, something here must be overriding it
    facets = $solr.get_facets({:q => "recordType_s:person", "facet.sort" => "asc", :facet => "true"}, ["titleLetter_s"])
    @alphabet = facets["titleLetter_s"]
  end

  def show
    id = params[:id]
    @person = $solr.query({:q => "id:#{id}", :fq => "recordType_s:person"})[:docs][0]

    @docs = $solr.query({:qfield => "personID_ss", :qtext => id})
    @cases = $solr.query({:q => "personID_ss:#{id}", :fq => "recordType_s:caseid"})
    rdf = Relationships.query_one_removed(id)
    @rdfresults = JSON.parse(rdf.to_json)

  end

  def network
    @id = params[:id]
    @type = params[:type]
    tree = Hypertree.new(@id, @type)
    @res = tree.json
    respond_to do |format|
      # optional to avoid all the header / footer
      format.html { render layout: false }
      format.json { render :json => tree.raw_res.to_json }
      format.xml { render :xml => tree.raw_res.to_xml }
    end
  end

end