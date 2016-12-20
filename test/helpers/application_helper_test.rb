require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  # this fools the tests into thinking that this is the params object from a request
  # but it is called from the helper itself not the test so if you want something besides 
  # cases / all it will be a problem
  def params
    { :controller => "cases", :action => "all" }
  end

  def setup
    @solr_json = [
          "{\"label\":\"Oakley, Eliza\",\"id\":\"per.000046\"}",
          "{\"label\":\"Hiort, Henry\",\"id\":\"per.000011\"}"
        ]
  end

  test "format_list with json" do
    assert_equal format_list(@solr_json), "<ul><li><a href=\"/doc/per.000046\">Oakley, Eliza</a></li><li><a href=\"/doc/per.000011\">Hiort, Henry</a></li></ul>"
  end

  test "format_list with invalid json" do
    items = ["just a normal solr string"]
    assert_equal format_list(items), "<ul><li class='a'>just a normal solr string</li></ul>"
  end

  test "format_list for people" do
    assert_equal format_list(@solr_json, "person"), "<ul><li><a href=\"/people/per.000046\">Oakley, Eliza</a></li><li><a href=\"/people/per.000011\">Hiort, Henry</a></li></ul>"
  end

  test "metadata_builder" do
    assert_equal metadata_builder("People", @solr_json), "<p><strong>People: </strong><p><a href=\"/doc/per.000046\">Oakley, Eliza</a> </p><p><a href=\"/doc/per.000011\">Hiort, Henry</a> </p></p>"
  end

  test "metadata_people_list" do
    assert_equal metadata_people_list(@solr_json), "<ul><li>Oakley, Eliza <span class='source_date'></span> <span class='source_note'>[<a href=\"/doc/per.000046\">source</a>]</span></li><li>Hiort, Henry <span class='source_date'></span> <span class='source_note'>[<a href=\"/doc/per.000011\">source</a>]</span></li></ul>"
  end

  test "jsonify" do
    assert_equal jsonify(@solr_json), [{"label"=>"Oakley, Eliza", "id"=>"per.000046"}, {"label"=>"Hiort, Henry", "id"=>"per.000011"}]
  end

  test "jsonify_bad_data" do
    bad = ["{\"label\":\"Oakley, Eliza\", \"id\":\"thing\"}}}"]
    assert_equal jsonify(bad), bad
  end

end
