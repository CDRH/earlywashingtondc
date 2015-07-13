# Does not involve active record, perhaps it should
# This is like a poor man's model because it feels right to
# put the RDF retrieval here, but very wrong at the same time.
# Perhaps I should write a gem instead?

# Note I tried using the active_rdf gem but had issues with it from the start
# so that's how we come to be here, today

class Relationships
  # @rdf = CONFIG['rdf_file']
  @@prefixes = %{PREFIX #{CONFIG['prefix_owl']} 
                 PREFIX #{CONFIG['prefix_rdf']}
                 PREFIX rdf: <http://www.w3.org/2000/01/rdf-schema#>}
  @@rdf = RDF::Repository.load("public/relationships.rdf")

  def self.query_one_removed(person)
    puts "Creating sparql query for single individual's immediate relationships"
    rdfquery = SPARQL.parse("#{@@prefixes} SELECT ?rel1 ?per1 ?name1 WHERE 
                            { osrdf:#{person} ?rel1 ?per1 . 
                              ?per1 oscys:fullName ?name1
                            }")
    res = @@rdf.query(rdfquery)
    return res
  end

  def self.query_two_removed_all(person)
    Timeout::timeout(10) do
      puts "Creating sparql query for ALL two removed relationship for #{person}"
      rdfquery = SPARQL.parse(%{#{@@prefixes} SELECT ?name0 ?name1 ?rel01 ?per1 ?name1 ?rel12 ?per2 ?name2
                  WHERE {
                    osrdf:#{person} ?rel01 ?per1 .
                    ?per1 ?rel12 ?per2 .
                    osrdf:#{person} oscys:fullName ?name0 .
                    ?per1 oscys:fullName ?name1 .
                    ?per2 oscys:fullName ?name2
                    FILTER ( ?per2 != osrdf:#{person} )
                    }})
      res = @@rdf.query(rdfquery)
      return res
    end
  end

  # this could use the same query as query_two_removed_all but it is slower so
  # in the interests of keeping things faster and also more clear, separating the sparql queries
  def self.query_two_removed_type(person, type)
    Timeout::timeout(10) do
      # the relationship properties are matched from the OWL file
      puts "Creating sparql query for only #{type} two removed relationship for #{person}"
      # TODO grab the FROMs from a config file instead of hardcoding them
      rdfquery = SPARQL.parse(%{#{@@prefixes} SELECT ?name0 ?name1 ?rel01 ?per1 ?name1 ?rel12 ?per2 ?name2
                  FROM <http://rosie.unl.edu/jessica/oscys_test.owl>
                  FROM <http://rosie.unl.edu/jessica/turtle.ttl>
                  WHERE {
                    ?rel01 rdf:subPropertyOf oscys:#{type} .
                    ?rel12 rdf:subPropertyOf oscys:#{type} .
                    osrdf:#{person} ?rel01 ?per1 .
                    ?per1 ?rel12 ?per2 .
                    osrdf:#{person} oscys:fullName ?name0 .
                    ?per1 oscys:fullName ?name1 .
                    ?per2 oscys:fullName ?name2
                    FILTER ( ?per2 != osrdf:#{person} )
                    }})
      res = @@rdf.query(rdfquery)
      return res
    end
  end

end