require 'test_helper'

class DocumentsHelperTest < ActionView::TestCase
  include DocumentsHelper
  include ApplicationHelper

  def params
    { :controller => "documents", 
      :action => "search", 
      :facet => "caseid", 
      :sort => "title",
      :qfield => "id",
      :qtext => "case.000001" }
  end

  doc = { "title" => "Roverandum", 
          "id" => "book.000001" }

  test "facet_maker" do
    assert_equal facet_maker({"caseid" => 11, "documents" => 98}), "<a href=\"/search?facet=caseid&amp;qfield=id&amp;qtext=case.000001&amp;sort=title\">All Results</a> <a class=\"selected\" href=\"/search?facet=caseid&amp;qfield=id&amp;qtext=case.000001&amp;sort=title\">Case <span class='badge'>11</span></a> <a class=\"\" href=\"/search?facet=documents&amp;qfield=id&amp;qtext=case.000001&amp;sort=title\">Documents <span class='badge'>98</span></a>"
  end

  test "facet_maker with empty facets" do
    assert_equal facet_maker({}), "<a href=\"/search?facet=caseid&amp;qfield=id&amp;qtext=case.000001&amp;sort=title\">All Results</a>"
  end

  test "selected_facet?" do
    assert_equal selected_facet?("caseid", "caseid"), "selected"
  end

  test "selected_facet? not selected" do
    assert_equal selected_facet?("title", "caseid"), nil
  end

  test "selected_sort?" do
    assert_equal selected_sort?("title", "title"), "selected"
  end

  test "selected_sort? not selected" do
    assert_equal selected_sort?("date", "title"), nil
  end

  # Until I figure out a better way to fake the params hash
  # these aren't going to work
  # test "facet_results" do
  #   assert_equal facet_results("people")[:facet], "people"
  # end

  # test "facet_results with nil" do
  #   assert_nil facet_results[:facet]
  # end

  test "search_result_link no date" do
    assert_equal search_result_link(doc), "<a href=\"/doc/book.000001\">Roverandum</a>"
  end

  test "search_result_link with date" do
    withDate = doc.clone
    withDate["dateDisplay"] = "December 18, 1888"
    assert_equal search_result_link(withDate), "<a href=\"/doc/book.000001\">Roverandum (December 18, 1888)</a>"
  end

  # this has the same problem with the params hash
  # test "sort_results" do
  # end

  # when the params are better then test this without a facet
  test "query_display" do
    assert_equal query_display, "case.000001 (caseid)"
  end

end
