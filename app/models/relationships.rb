# Does not involve active record, perhaps it should
# Put this in models because because it feels right to
# put the RDF retrieval here, but very wrong at the same time.
# Perhaps I should write a gem instead?

# Note I tried using the active_rdf gem but had issues with it from the start
# so that's how we come to be here, today

class Relationships
  attr_reader :ready
  attr_accessor :rdf_file, :owl_file, :sparqler, :prefixes

  def initialize
    @rdf_file = CONFIG['rdf_file']
    @owl_file = CONFIG['owl_file']
    @sparqler = CONFIG['sparqler']
    # the prefixes will not be returned in json format but can be used for forming the queries
    @prefixes = %{PREFIX #{CONFIG['prefix_owl']} 
                 PREFIX #{CONFIG['prefix_rdf']}
                 PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>}

    test_query = self.query("{ ?s ?p ?o } LIMIT 1")
    @ready = !test_query.nil?
    Rails.logger.error "Warning: Connection with RDF server not established!" if !@ready
  end

  def query(query_string, include_owl=false, format="json", order_by=nil)
    url = _build_url(query_string, order_by, include_owl, format)
    puts "Querying rdf with #{url}"
    begin
      return Net::HTTP.get(URI.parse(url))
    rescue => e
      Rails.logger.error "There was an error while querying rdf / parsing: #{e}"
      return nil
    end
  end

  def query_by_connection(type, format="json")
    query_string = %{
      { ?per1 oscys:#{type} ?per2 .
        ?per1 oscys:fullName ?per1name .
        ?per2 oscys:fullName ?per2name .
      }
    }
    return query(query_string, false, format)
  end

  def query_first_relation(person_id1, person_id2)
    query_string = %{ {
       osrdf:#{person_id1} ?rel osrdf:#{person_id2} .
       osrdf:#{person_id1} oscys:fullName ?name1 .
       osrdf:#{person_id2} oscys:fullName ?name2 
     }
    }
    return query(query_string)
  end

  def query_second_relation(person_id1, person_id2)
    query_string = %{ {
       BIND(osrdf:#{person_id1} AS ?per1) .
       BIND(osrdf:#{person_id2} AS ?goal) .
       ?per1 ?rel12 ?per2 .
       ?per2 ?rel2g ?goal .
       ?per1 oscys:fullName ?name1 .
       ?per2 oscys:fullName ?name2 .
       ?goal oscys:fullName ?nameg
     }
    }
    return query(query_string)
  end

  def query_third_relation(person_id1, person_id2)
    query_string = %{ {
       BIND(osrdf:#{person_id1} AS ?per1) .
       BIND(osrdf:#{person_id2} AS ?goal) .
       ?per1 ?rel12 ?per2 .
       ?per2 ?rel23 ?per3 .
       ?per3 ?rel3g ?goal .
       ?per1 oscys:fullName ?name1 .
       ?per2 oscys:fullName ?name2 .
       ?per3 oscys:fullName ?name3 .
       ?goal oscys:fullName ?nameg .
       FILTER ( ?per3 != ?per1 ) .
       FILTER (?per2 != ?goal )
     }
    }
    return query(query_string)
  end

  def query_fourth_relation(person_id1, person_id2)
    query_string = %{ {
       BIND(osrdf:#{person_id1} AS ?per1) .
       BIND(osrdf:#{person_id2} AS ?goal) .
       ?per1 ?rel12 ?per2 .
       ?per2 ?rel23 ?per3 .
       ?per3 ?rel34 ?per4 .
       ?per4 ?rel4g ?goal .
       ?per1 oscys:fullName ?name1 .
       ?per2 oscys:fullName ?name2 .
       ?per3 oscys:fullName ?name3 .
       ?per4 oscys:fullName ?name4 .
       ?goal oscys:fullName ?nameg .
       FILTER ( ?per3 != ?per1 ) .
       FILTER (?per2 != ?per4 )
       FILTER (?per3 != ?goal )
     }
    }
    return query(query_string)
  end

  def query_one_removed(person_id, format="json")
    query_string = %{ { osrdf:#{person_id} ?rel1 ?per1 . 
                      ?per1 oscys:fullName ?name1 } }
    order_by = "?rel1 ?name1"
    return query(query_string, false, format, order_by)
  end

  def query_two_removed(person_id, format="json", type=nil)
    if type.nil?
      query_string = %{ {
                  osrdf:#{person_id} ?rel01 ?per1 .
                  OPTIONAL { 
                    ?per1 ?rel12 ?per2 .
                    ?per2 oscys:fullName ?name2 .
                  }
                  osrdf:#{person_id} oscys:fullName ?name0 .
                  ?per1 oscys:fullName ?name1 .
                  OPTIONAL { ?rel01 rdfs:subPropertyOf ?rel01type } .
                  OPTIONAL { ?rel12 rdfs:subPropertyOf ?rel12type } .
                  FILTER ( ?per2 != osrdf:#{person_id} )
                  }}
      return query(query_string, true, format)
    else
      query_string = %{ {
                  BIND(oscys:#{type} as ?rel01type) .
                  BIND(oscys:#{type} as ?rel12type) .
                  ?rel01 rdfs:subPropertyOf oscys:#{type} .
                  ?rel12 rdfs:subPropertyOf oscys:#{type} .
                  osrdf:#{person_id} ?rel01 ?per1 .
                  OPTIONAL { 
                    ?per1 ?rel12 ?per2 .
                    ?per2 oscys:fullName ?name2 .
                  }
                  osrdf:#{person_id} oscys:fullName ?name0 .
                  ?per1 oscys:fullName ?name1 .
                  FILTER ( ?per2 != osrdf:#{person_id} )
                  }}
      return query(query_string, true, format)
    end
  end

  private

  def _build_url(query_string="{}", order_by=nil, include_owl=false, format="json")
    graphs = include_owl ? "FROM <#{@rdf_file}> FROM <#{@owl_file}>" : "FROM <#{@rdf_file}>"
    order = order_by.nil? ? "" :  " ORDER BY #{order_by}"
    query = %{#{@prefixes} SELECT * #{graphs} WHERE #{query_string} #{order}}.squeeze(" ")
    query_url = URI.escape(query)
    url = "#{@sparqler}?query=#{query_url}&format=#{format}"
  end

end
