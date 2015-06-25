class PeopleController < ApplicationController
  def index
    # list all people
  end

  def show
    id = params[:id]
    @person = @@solr.query({:q => "id:#{id}"})[:docs][0]

    @docs = @@solr.query({:qfield => "peopleID_ss", :qtext => id})

    rdfquery = SPARQL.parse("#{@@prefixes} SELECT ?rel1 ?per1 ?name1 WHERE 
                            { osrdf:#{id} ?rel1 ?per1 . 
                              ?per1 oscys:fullName ?name1
                            }")
    rdf = @@rdf.query(rdfquery)
    @rdfresults = JSON.parse(rdf.to_json)

  end

end