class PeopleController < ApplicationController

  def index
    @page_class = "people"

     # TODO the rsolr gem reallllllly shouldn't need facet => true, still not sure why that is happening
    facet = $solr.get_facets({
      :q => "recordType_s:caseid", :facet => "true", 
      "facet.sort" => "asc", "facet.limit" => "-1"}, ["attorneyData_ss", "plaintiffData_ss", "defendantData_ss"])

    # @attorney_facet = dropdownify_data_facets(facet['attorneyData_ss'])
    @plaintiff_facet = dropdownify_data_facets(facet['plaintiffData_ss'])
    @defendant_facet = dropdownify_data_facets(facet['defendantData_ss'])
    attorney_facets = $solr.get_facets(
      {:q => "recordType_s:document", 
      "facet.sort" => "asc", 
      "facet.limit" => "-1", 
      :facet => "true",
      "facet.mincount" => "1"}, ["attorneyData_ss"])

    @attorneys = dropdownify_data_facets(attorney_facets["attorneyData_ss"], false)
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

    @docs = $solr.query({:qfield => "personID_ss", :qtext => id, :sort => "date asc"})
    @cases = $solr.query({:q => "personID_ss:#{id}", :fq => "recordType_s:caseid"})

    respond_to do |format|
      format.html {
        @rdfresults = $rdf_ready ? JSON.parse(Relationships.new.query_one_removed(id)) : nil
      }
      format.json do
        res = $rdf_ready ? Relationships.new.query_one_removed(id)
          : { :error => "Relationships currently unavailable" }
        render :json => res
      end
      format.xml do
        res = $rdf_ready ? Relationships.new.query_one_removed(id, "xml")
          : "<xml><error>Relationships currently unavailable</error></xml>"
        render :xml => res
      end
    end
  end

  def network
    @page_class = "visualization"
    @id = params[:id]

    # TODO could this cause exceptions in the future?
    @person_url = request.base_url + network_vis_path.sub(/per\.[0-9]{6}/, "")
    respond_to do |format|
      format.html { 
        hypertree_info = $rdf_ready ? Hypertree.new(@id, true).json : nil
        @res = hypertree_info[:info]
        @notes = hypertree_info[:notes]
        # optional to avoid all the header / footer
        render layout: false
      }
      format.json do
        res = $rdf_ready ? Relationships.new.query_two_removed(@id, "json")
          : { :error => "Network for #{@id} currently unavailable" }
        render :json => res
      end
      format.xml do
        res = $rdf_ready ? Relationships.new.query_two_removed(@id, "xml")
          : "<xml><error>Network for #{@id} currently unavailable</error></xml>"
        render :xml => res
      end
    end
  end

  def relationships
    # solr request to populate dropdown
    # currently only using attorneys pulled from document information
    @page_class = "people"
    facets = $solr.get_facets(
      {:q => "recordType_s:document", 
      "facet.sort" => "asc", 
      "facet.limit" => "-1", 
      :facet => "true",
      "facet.mincount" => "1"}, ["attorneyData_ss"])
    @people = dropdownify_data_facets(facets["attorneyData_ss"], false)

    if $rdf_ready && params["per1id"] && params["per2id"]
      # rdf queries to get the relationships
      rdf = Relationships.new
      @relationOne = _get_rdf_good_stuff(rdf.query_first_relation(params["per1id"], params["per2id"]))
      @relationTwo = _get_rdf_good_stuff(rdf.query_second_relation(params["per1id"], params["per2id"]))
      @relationThree = _get_rdf_good_stuff(rdf.query_third_relation(params["per1id"], params["per2id"]))
      @relationFour = _get_rdf_good_stuff(rdf.query_fourth_relation(params["per1id"], params["per2id"]))
    end
  end

  def connection_type
    @page_class = "people"
    if $rdf_ready
      rdf = Relationships.new
      respond_to do |format|
        format.html { @res = _get_rdf_good_stuff(rdf.query_by_connection(params[:type])) }
        format.json { render :json => rdf.query_by_connection(params[:type]) }
        format.xml { render :xml => rdf.query_by_connection(params[:type], "xml") }
      end
    else
      respond_to do |format|
        format.html { @res = nil }
        format.json { render :json => { :error => "Relationships currently unavailable" } }
        format.xml { render :xml => "<xml><error>Relationships currently unavailable</error></xml>" }
      end
    end
  end

  private

  def _get_rdf_good_stuff(raw)
    begin
      json = JSON.parse(raw)
      if json.has_key?("results") && json["results"].has_key?("bindings")
        return json["results"]["bindings"]
      end
    rescue => e
      return nil
    end
  end
end
