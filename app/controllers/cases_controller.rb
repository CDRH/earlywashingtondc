class CasesController < ApplicationController
  def index
    @page_class = "cases"

    # TODO facet.mincount and facet.limit shouldn't need to be set because they are
    # in the defaults so there must be something wrong with my gem
    doc_facets = $solr.get_facets({
      :q => "recordType_s:document", 
      # :facet => "true", 
      "facet.sort" => "index",
      "facet.mincount" => "1",
      "facet.limit" => "-1"
      }, ["term_ss", "subCategory", "places"])
    case_facets = $solr.get_facets({
      :q => "recordType_s:caseid", 
      # :facet => "true", 
      "facet.sort" => "index",
      "facet.mincount" => "1",
      "facet.limit" => "-1"}, ["jurisdiction_ss", "outcome_ss", "claims_ss"])
    @term_facet = dropdownify_facets(doc_facets['term_ss'], true)
    @subCategory_facet = dropdownify_facets(doc_facets['subCategory'])
    @claims_facet = dropdownify_facets(case_facets['claims_ss'])
    @jurisdiction_facet = dropdownify_facets(case_facets['jurisdiction_ss'])
    @outcome_facet = dropdownify_facets(case_facets['outcome_ss'])
    @places_facet = dropdownify_facets(doc_facets['places'])
  end
  
  def all
    @page_class = "search_results"
    sort = params[:sort] ? "#{params[:sort]} asc" : "title asc"
    _index_finder({:fqfield => "recordType_s", :fqtext => "caseid", :sort => sort})
  end
  
  def annotated
    @page_class = "search_results"
    sort = params[:sort] ? "#{params[:sort]} asc" : "title asc"
    _index_finder({
      :fqfield => "recordType_s", :fqtext => "caseid", 
      :qfield => "caseidHasNarrative_s", :qtext => "true",
      :sort => sort
    })
  end

  def show
    @page_class = "cases"
    @case = $solr.get_item_by_id(params[:id])
    url = @case["uriHTML"]
    @annotated = Net::HTTP.get(URI.parse(url)) if url
  end

end
