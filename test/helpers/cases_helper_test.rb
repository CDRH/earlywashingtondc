require 'test_helper'

class CasesHelperTest < ActionView::TestCase
  include CasesHelper
  include ApplicationHelper

  array = ["a", "a", "b", "c", "d"]

  test "find_unique_strings" do
    assert_equal "a, b, c, d", find_unique_strings(array)
  end

  test "find_unique" do
    assert_equal ["a", "b", "c", "d"], find_unique(array)
  end

  test "people_list" do
    assert_equal people_list(array), "<ul><li>a</li><li>b</li><li>c</li><li>d</li></ul>"
  end

end
