# Does not involve active record, perhaps it should
# Put this in models because because it feels right to
# put the RDF retrieval here, but very wrong at the same time.
# Perhaps I should write a gem instead?

# Note I tried using the active_rdf gem but had issues with it from the start
# so that's how we come to be here, today

class Relationships
  attr_accessor :rdf_file, :owl_file, :sparqler, :prefixes

  def initialize
    @rdf_file = CONFIG['rdf_file']
    @owl_file = CONFIG['owl_file']
    @sparqler = CONFIG['sparqler']
    # the prefixes will not be returned in json format but can be used for forming the queries
    @prefixes = %{PREFIX #{CONFIG['prefix_owl']} 
                 PREFIX #{CONFIG['prefix_rdf']}
                 PREFIX rdf: <http://www.w3.org/2000/01/rdf-schema#>}
  end

  def query(query_string, include_owl=false, format="json")
    url = _build_url(query_string, include_owl, format)
    puts "Querying rdf with #{url}"
    begin
      return Net::HTTP.get(URI.parse(url))
    rescue => e
      puts "There was an error while querying rdf / parsing: #{e}"
      return nil
    end
  end

  def query_one_removed(person_id, format="json")
    query_string = %{ { osrdf:#{person_id} ?rel1 ?per1 . 
                      ?per1 oscys:fullName ?name1 } }
    return query(query_string, false, format)
  end

  def query_two_removed(person_id, format="json", type=nil)
    if type.nil?
      query_string = %{ {
                  osrdf:#{person_id} ?rel01 ?per1 .
                  ?per1 ?rel12 ?per2 .
                  osrdf:#{person_id} oscys:fullName ?name0 .
                  ?per1 oscys:fullName ?name1 .
                  ?per2 oscys:fullName ?name2
                  FILTER ( ?per2 != osrdf:#{person_id} )
                  }}
      return query(query_string, false, format)
    else
      query_string = %{ {
                  ?rel01 rdf:subPropertyOf oscys:#{type} .
                  ?rel12 rdf:subPropertyOf oscys:#{type} .
                  osrdf:#{person_id} ?rel01 ?per1 .
                  ?per1 ?rel12 ?per2 .
                  osrdf:#{person_id} oscys:fullName ?name0 .
                  ?per1 oscys:fullName ?name1 .
                  ?per2 oscys:fullName ?name2
                  FILTER ( ?per2 != osrdf:#{person_id} )
                  }}
      return query(query_string, true, format)
    end
  end

  def _build_url(query_string="{}", include_owl=false, format="json")
    graphs = include_owl ? "FROM <#{@rdf_file}> FROM <#{@owl_file}>" : "FROM <#{@rdf_file}>"
    query = %{#{@prefixes} SELECT * #{graphs} WHERE #{query_string}}.squeeze(" ")
    query_url = URI.escape(query)
    url = "#{@sparqler}?query=#{query_url}&format=#{format}"
  end

end