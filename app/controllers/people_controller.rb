class PeopleController < ApplicationController
  def index
    # list all people
  end

  def show
    id = params[:id]
    @docs = @@solr.query({:qfield => "peopleID_ss", :qtext => id})

    rdfquery = SPARQL.parse("#{@@prefixes} SELECT ?rel1 ?name1 WHERE 
                            { osrdf:#{id} ?rel1 ?per1 . 
                              ?per1 oscys:fullName ?name1 
                            }")
    rdf = @@rdf.query(rdfquery)
    @rdfresults = JSON.parse(rdf.to_json)

  end

end