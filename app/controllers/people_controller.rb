class PeopleController < ApplicationController
	
  def index
  end
		
		
  def all
    options = {:fq => "recordType_s:person"}
    if params.has_key?(:page) && params[:page].to_i > 0
      options[:page] = params[:page]
    end
    @people = @@solr.query(options)
    @total_people = @people[:num_found]
  end

  def show
    id = params[:id]
    @person = @@solr.query({:q => "id:#{id}", :fq => "recordType_s:person"})[:docs][0]

    @docs = @@solr.query({:qfield => "peopleID_ss", :qtext => id})

    puts "PREFIXES #{@@prefixes}"
    rdfquery = SPARQL.parse("#{@@prefixes} SELECT ?rel1 ?per1 ?name1 WHERE 
                            { osrdf:#{id} ?rel1 ?per1 . 
                              ?per1 oscys:fullName ?name1
                            }")
    rdf = @@rdf.query(rdfquery)
    @rdfresults = JSON.parse(rdf.to_json)

  end

  def test
    solr_url = "http://rosie.unl.edu:8080/solr/api_oscys_test_alpha"

    solr = RSolrCdrh::Query.new(solr_url)

    @res = solr.query({:q => "id:fakeid"})
  end

end