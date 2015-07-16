class PeopleController < ApplicationController
	
  def index
     # TODO the rsolr gem reallllllly shouldn't need facet => true, still not sure why that is happening
    facet = $solr.get_facets({
      :q => "recordType_s:document", :facet => "true", 
      "facet.sort" => "asc", "facet.limit" => "-1"}, ["attorneyData_ss", "plaintiffData_ss", "defendantData_ss"])
    occupation = $solr.get_facets({:q => "recordType_s:person", :facet => "true",
      "facet.sort" => "asc", "facet.limit" => "-1"}, ["personOccupation_ss"])
    # @attorney_facet = facet['attorneyData_ss']
    @attorney_facet = dropdownify_data_facets(facet['attorneyData_ss'])
    @plaintiff_facet = dropdownify_data_facets(facet['plaintiffData_ss'])
    @defendant_facet = dropdownify_data_facets(facet['defendantData_ss'])
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

  def browse
    # this is a little goofy but the form_tag doesn't like me putting person_path in there without an id
    # even when I open person_path to enable POST.  Strange
    redirect_to person_path(params[:id])
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