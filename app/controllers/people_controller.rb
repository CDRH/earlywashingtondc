class PeopleController < ApplicationController

  def index
	  @page_class = "people"

     # TODO the rsolr gem reallllllly shouldn't need facet => true, still not sure why that is happening
    facet = $solr.get_facets({
      :q => "recordType_s:caseid", :facet => "true", 
      "facet.sort" => "asc", "facet.limit" => "-1"}, ["attorneyData_ss", "plaintiffData_ss", "defendantData_ss"])

    @attorney_facet = dropdownify_data_facets(facet['attorneyData_ss'])
    @plaintiff_facet = dropdownify_data_facets(facet['plaintiffData_ss'])
    @defendant_facet = dropdownify_data_facets(facet['defendantData_ss'])
    
    # TODO this isn't right, the gem shouldn't need "facet = true" so I'm not sure what's going on
    # it already has facet = true as a default in the gem, something here must be overriding it
    facets = $solr.get_facets({:q => "recordType_s:person", "facet.sort" => "asc", :facet => "true"}, ["titleLetter_s"])
    @alphabet = facets["titleLetter_s"]

    
  end
		
  def all
    @page_class = "people"

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
    @page_class = "people"
    id = params[:id]
    @person = $solr.get_item_by_id(id)

    @docs = $solr.query({:qfield => "personID_ss", :qtext => id})
    @cases = $solr.query({:q => "personID_ss:#{id}", :fq => "recordType_s:caseid"})

    respond_to do |format|
      format.html { 
        @rdfresults = JSON.parse(Relationships.new.query_one_removed(id)) 
      }
      format.json { render :json => Relationships.new.query_one_removed(id) }
      format.xml { render :xml => Relationships.new.query_one_removed(id, "xml") }
    end
  end

  def network
    @page_class = "visualization"
    @id = params[:id]
    @type = params[:type]

    # TODO could this cause exceptions in the future?
    @person_url = request.base_url + network_vis_path.sub(/per\.[0-9]{6}/, "")
    respond_to do |format|
      format.html { 
        @res = Hypertree.new(@id, @type, true).json
        # optional to avoid all the header / footer
        render layout: false
      }
      format.json { render :json => Relationships.new.query_two_removed(@id, "json", @type) }
      format.xml { render :xml => Relationships.new.query_two_removed(@id, "xml", @type) }
    end
    


    
  end
end