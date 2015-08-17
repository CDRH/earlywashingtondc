require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  # this fools the tests into thinking that this is the params object from a request
  # but it is called from the helper itself not the test so if you want something besides 
  # cases / all it will be a problem
  def params
    { :controller => "cases", :action => "all" }
  end

  solr_json = [
          "{\"label\":\"Oakley, Eliza\",\"id\":\"per.000046\"}",
          "{\"label\":\"Hiort, Henry\",\"id\":\"per.000011\"}"
        ]

  test "_add_paginator_options" do
    assert_equal _add_paginator_options(1..3), "<li><a href=\"/cases/all?page=1\">1</a></li><li><a href=\"/cases/all?page=2\">2</a></li><li><a href=\"/cases/all?page=3\">3</a></li>"
  end

  test "paginator_numbers" do
    assert_equal paginator_numbers(9), "<li class='active'><a href=\"/cases/all?page=1\">1</a></li><li><a href=\"/cases/all?page=2\">2</a></li><li><a href=\"/cases/all?page=3\">3</a></li><li><a href=\"/cases/all?page=4\">4</a></li><li class='disabled'><span>...</span></li><li><a href=\"/cases/all?page=9\">9</a></li>"
  end

  test "to_page" do
    assert_equal to_page(3), {:controller => "cases", :action => "all", :page => "3"}
  end

  test "format_list with json" do
    assert_equal format_list(solr_json), "<ul><li><a href=\"/doc/per.000046\">Oakley, Eliza</a></li><li><a href=\"/doc/per.000011\">Hiort, Henry</a></li></ul>"
  end

  test "format_list with invalid json" do
    items = ["just a normal solr string"]
    assert_equal format_list(items), "<ul><li>just a normal solr string</li></ul>"
  end

  test "format_list for people" do
    assert_equal format_list(solr_json, "person"), "<ul><li><a href=\"/people/per.000046\">Oakley, Eliza</a></li><li><a href=\"/people/per.000011\">Hiort, Henry</a></li></ul>"
  end

  test "metadata_builder" do
    assert_equal metadata_builder("People", solr_json), "<p><strong>People: </strong><p><a href=\"/doc/per.000046\">Oakley, Eliza</a> </p><p><a href=\"/doc/per.000011\">Hiort, Henry</a> </p></p>"
  end

  test "metadata_people_list" do
    assert_equal metadata_people_list(solr_json), "<ul><li>Oakley, Eliza <span class='source_date'></span> <span class='source_note'>[<a href=\"/doc/per.000046\">source</a>]</span></li><li>Hiort, Henry <span class='source_date'></span> <span class='source_note'>[<a href=\"/doc/per.000011\">source</a>]</span></li></ul>"
  end

  ##########################
  # Application Controller #
  ##########################

  test "format_date" do
    assert_equal format_date("2015-09"), "September 2015"
  end
end