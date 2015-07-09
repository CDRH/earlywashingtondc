class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # set up SOLR configuration for the website
  solr_url = CONFIG['solr_url']
  if solr_url.nil?
    raise "No Solr URL found, cannot continue"
  else
    @@solr = RSolrCdrh::Query.new(solr_url, [])
    # set default to look for just documents
    @@solr.set_default_query_params({
      # :fq => ['category:(NOT "Case" NOT "People")']
      :fq => ['recordType_s:document']
    })
    @@solr.set_default_facet_fields({
      :fq => ['recordType_s:document']
    })
  end

  # set up the RDF linked data
  @@rdf = RDF::Repository.load("public/relationships.rdf")
  @@prefixes = "PREFIX #{CONFIG['prefix_owl']} PREFIX #{CONFIG['prefix_rdf']}"
end
