class CasesController < ApplicationController
  def index
    @cases = $solr.query({:fqfield => "recordType_s", :fqtext => "caseid"})
  end

  def show
    @docs = $solr.query({:qfield => "caseID_ss", :qtext => params[:id]})
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
