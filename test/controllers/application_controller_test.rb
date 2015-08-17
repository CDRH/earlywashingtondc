require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  
  test "new rails app should include solr" do
    assert_not_nil $solr
    assert_equal $solr.default_query_params, {:q=>"*:*", :fq=>["recordType_s:document"], :start=>0, :rows=>50, :sort=>"title asc"}
    assert_equal $solr.default_facet_params, {:q=>"*:*", :fq=>["recordType_s:documents"], :start=>0, :rows=>0, :facet=>"true", "facet.field"=>[], "facet.sort"=>"index"}
  end

  # TODO figure out how to test private methods in application controller
  # test "format_date" do
  #   @controller.format_date("2016-09")
  # end
end