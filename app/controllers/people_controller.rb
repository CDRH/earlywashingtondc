class PeopleController < ApplicationController
	
  def index
  end
		
		
  def all
    _index_finder({:fq => "recordType_s:person"})
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