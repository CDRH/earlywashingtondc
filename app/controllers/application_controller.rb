class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # set up SOLR configuration for the website
  solr_url = CONFIG['solr_url']
  if solr_url.nil?
    raise "No Solr URL found, cannot continue"
  else
    $solr = RSolrCdrh::Query.new(solr_url, [])
    # set default to look for just documents
    $solr.set_default_query_params({
      # :fq => ['category:(NOT "Case" NOT "People")']
      :fq => ['recordType_s:document']
    })
    $solr.set_default_facet_fields({
      :fq => ['recordType_s:document']
    })
  end

  def _index_finder(options={})
    if params.has_key?(:page) && params[:page].to_i > 0
      options[:page] = params[:page]
    end
    @docs = $solr.query(options)
    @total_found = @docs[:num_found]
    # default response is 50 pages, divide and round up for all
    @total_pages = (@total_found.to_f/50).ceil
  end

end
