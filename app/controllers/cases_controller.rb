class CasesController < ApplicationController
  def index
    @page_class = "cases"

    # TODO the rsolr gem reallllllly shouldn't need facet => true, still not sure why that is happening
    facet = $solr.get_facets({:q => "recordType_s:document", :facet => "true", "facet.sort" => "index"}, ["term_ss", "subCategory", "jurisdiction_ss", "places"])
    @term_facet = dropdownify_facets(facet['term_ss'], true)
    @subCategory_facet = dropdownify_facets(facet['subCategory'])
    @jurisdiction_facet = dropdownify_facets(facet['jurisdiction_ss'])
    @places_facet = dropdownify_facets(facet['places'])
  end
  
  def all
    @page_class = "search_results"
    _index_finder({:fqfield => "recordType_s", :fqtext => "caseid"})
  end
  
  def annotated
    @page_class = "search_results"
    # TODO at some point these need to be flagged as specifically annotated
    _index_finder({
      :fqfield => "recordType_s", :fqtext => "caseid", 
      :qfield => "caseidHasNarrative_s", :qtext => "true"})
  end

  def show
    @page_class = "cases"
    @case = $solr.get_item_by_id(params[:id])
    url = @case["uriHTML"]
    @annotated = Net::HTTP.get(URI.parse(url)) if url
  end

end
