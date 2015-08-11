require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:page_class)
  end

  test "should get search" do
    get :search, {'qfield' => 'text', 'qtext' => 'henry'}
    assert_response :success
    assert_not_nil assigns(:docs)
    assert_not_nil assigns(:categories)
    assert_not_nil assigns(:total_pages)
  end

  test "should post search" do
    post :search, {'qfield' => 'text', 'qtext' => 'henry'}
    assert_response :success
    assert_not_nil assigns(:docs)
    assert_not_nil assigns(:categories)
    assert_not_nil assigns(:total_pages)
  end

  test "should redirect person show" do
    get :show, {'id' => 'per.000001'}
    assert_response :redirect
    assert_redirected_to person_path('per.000001')
  end

  test "should redirect caseid show" do
    get :show, {'id' => 'oscys.caseid.0264'}
    assert_response :redirect
    assert_redirected_to case_path('oscys.caseid.0264')
  end

  test "should get document show" do
    get :show, {'id' => 'oscys.case.0265.001'}
    assert_response :success
    assert_not_nil assigns(:doc)
    assert_not_nil assigns(:res)
  end

  test "should get advancedsearch" do
    get :advancedsearch
    assert_response :success
    assert_not_nil assigns(:people)
    assert_not_nil assigns(:locations)
  end

  test "should post to dropdown" do
    get :dropdown
    assert_redirected_to search_path({:qtext => "", :qfield => ""})
  end

end
