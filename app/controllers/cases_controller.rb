class CasesController < ApplicationController
  def index
    # TODO the rsolr gem reallllllly shouldn't need facet => true, still not sure why that is happening
    facet = $solr.get_facets({:q => "recordType_s:document", :facet => "true"}, ["term_ss", "subCategory", "jurisdiction_ss", "places"])
    @term_facet = dropdownify_facets(facet['term_ss'])
    @subCategory_facet = dropdownify_facets(facet['subCategory'])
    @jurisdiction_facet = dropdownify_facets(facet['jurisdiction_ss'])
    @places_facet = dropdownify_facets(facet['places'])
  end
  
  def all
    _index_finder({:fqfield => "recordType_s", :fqtext => "caseid"})
  end
  
  def annotated
    # TODO at some point these need to be flagged as specifically annotated
    _index_finder({
      :fqfield => "recordType_s", :fqtext => "caseid", 
      :qfield => "caseidHasNarrative_s", :qtext => "true"})
  end

  def show
    # @docs = $solr.query({:qfield => "caseID_ss", :qtext => params[:id]})
    case_res = $solr.query({
      :qfield => "id", 
      :qtext => params[:id],
      :fqfield => "recordType_s",
      :fqtext => "caseid"
      })
    # @case = get_first_doc(case_res[:docs][0])
    @case = case_res[:docs][0]
  end

end
