class CasesController < ApplicationController
  def index
  end
  
  def all
    @cases = $solr.query({:fqfield => "recordType_s", :fqtext => "caseid"})
  end
  
  def annotated
    @cases = $solr.query({:fqfield => "recordType_s", :fqtext => "caseid"})

  end
  
  def documents
        options = {}
    if params.has_key?(:page) && params[:page].to_i > 0
      options[:page] = params[:page]
    end
    @docs = $solr.query(options)
    # default response is 50 pages, divide and round up for all
    @total_pages = (@docs[:num_found].to_f/50).ceil
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
