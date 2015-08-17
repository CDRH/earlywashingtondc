require 'test_helper'

class RelationshipsTest < ActionView::TestCase

  rel = Relationships.new

  test "testing" do
    assert_equal rel.rdf_file, "http://cdrhsites.unl.edu/data/projects/oscys/rdf/oscys.relationships.ttl"
    assert_equal rel.owl_file, "http://cdrhsites.unl.edu/data/projects/oscys/rdf/oscys.objectproperties.owl"
    assert_equal rel.sparqler, "http://cdrhsearch.unl.edu:3030/sparql"
    assert_equal rel.prefixes.squeeze(" "), "PREFIX oscys: <http://cdrhsites.unl.edu/data/projects/oscys/rdf/oscys.objectproperties.owl#> \n PREFIX osrdf: <http://cdrhsites.unl.edu/data/projects/oscys/rdf/oscys.relationships#>\n PREFIX rdf: <http://www.w3.org/2000/01/rdf-schema#>"
  end

  test "query simple" do
    res = rel.query("{ ?s ?p ?o }")
    begin
      json = JSON.parse(res)
      assert json.length > 0
    rescue => e
      assert false, "There was an error with the query #{e}"
    end
  end

  test "query xml" do
    res = rel.query("{ ?s ?p ?o }", false, "xml")
    assert res.include?("<sparql xmlns")
  end

  test "_build_url" do
    url = rel.send(:_build_url, "{ ?s ?p ?o }")
    assert_equal url, "http://cdrhsearch.unl.edu:3030/sparql?query=PREFIX%20oscys:%20%3Chttp://cdrhsites.unl.edu/data/projects/oscys/rdf/oscys.objectproperties.owl%23%3E%20%0A%20PREFIX%20osrdf:%20%3Chttp://cdrhsites.unl.edu/data/projects/oscys/rdf/oscys.relationships%23%3E%0A%20PREFIX%20rdf:%20%3Chttp://www.w3.org/2000/01/rdf-schema%23%3E%20SELECT%20*%20FROM%20%3Chttp://cdrhsites.unl.edu/data/projects/oscys/rdf/oscys.relationships.ttl%3E%20WHERE%20%7B%20?s%20?p%20?o%20%7D&format=json"
  end

end