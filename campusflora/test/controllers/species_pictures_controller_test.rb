require 'test_helper'

class SpeciesPicturesControllerTest < ActionController::TestCase
  setup do
    @species_picture = species_pictures(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:species_pictures)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create species_picture" do
    assert_difference('SpeciesPicture.count') do
      post :create, species_picture: {  }
    end

    assert_redirected_to species_picture_path(assigns(:species_picture))
  end

  test "should show species_picture" do
    get :show, id: @species_picture
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @species_picture
    assert_response :success
  end

  test "should update species_picture" do
    patch :update, id: @species_picture, species_picture: {  }
    assert_redirected_to species_picture_path(assigns(:species_picture))
  end

  test "should destroy species_picture" do
    assert_difference('SpeciesPicture.count', -1) do
      delete :destroy, id: @species_picture
    end

    assert_redirected_to species_pictures_path
  end
end
