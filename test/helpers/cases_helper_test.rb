require 'test_helper'

class CasesHelperTest < ActionView::TestCase
  include CasesHelper
  include ApplicationHelper

  array = ["a", "a", "b", "c", "d"]
  fake_people = [{"label" => "Dussault", "id" => "per.001721"}, {"label" => "ADussault", "id" => "per.138210"}]

  test "find_unique_strings" do
    assert_equal "a<br/>b<br/>c<br/>d", find_unique_strings(array)
  end

  test "find_unique" do
    assert_equal ["a", "b", "c", "d"], find_unique(array)
  end

  test "people_list" do
    assert_equal people_list(fake_people), "<ul><li><a href=\"/people/per.138210\">ADussault</a></li><li><a href=\"/people/per.001721\">Dussault</a></li></ul>"
  end

end
