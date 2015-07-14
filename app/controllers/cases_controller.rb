class CasesController < ApplicationController
  def index
  end
  
  def all
    _index_finder({:fqfield => "recordType_s", :fqtext => "caseid"})
  end
  
  def annotated
    # TODO at some point these need to be flagged as specifically annotated
    _index_finder({:fqfield => "recordType_s", :fqtext => "caseid"})
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
