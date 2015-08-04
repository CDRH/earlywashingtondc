class CasesController < ApplicationController
  def index
    @page_class = "cases"

    # TODO the rsolr gem reallllllly shouldn't need facet => true, still not sure why that is happening
    doc_facets = $solr.get_facets({:q => "recordType_s:document", :facet => "true", "facet.sort" => "index"}, ["term_ss", "subCategory", "places"])
    case_facets = $solr.get_facets({:q => "recordType_s:caseid", :facet => "true", "facet.sort" => "index"}, ["jurisdiction_ss"])
    @term_facet = dropdownify_facets(doc_facets['term_ss'], true)
    @subCategory_facet = dropdownify_facets(doc_facets['subCategory'])
    @jurisdiction_facet = dropdownify_facets(case_facets['jurisdiction_ss'])
    @places_facet = dropdownify_facets(doc_facets['places'])
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
