require 'test_helper'

class SpeciesLocationsControllerTest < ActionController::TestCase
  setup do
    @species_location = species_locations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:species_locations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create species_location" do
    assert_difference('SpeciesLocation.count') do
      post :create, species_location: {  }
    end

    assert_redirected_to species_location_path(assigns(:species_location))
  end

  test "should show species_location" do
    get :show, id: @species_location
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @species_location
    assert_response :success
  end

  test "should update species_location" do
    patch :update, id: @species_location, species_location: {  }
    assert_redirected_to species_location_path(assigns(:species_location))
  end

  test "should destroy species_location" do
    assert_difference('SpeciesLocation.count', -1) do
      delete :destroy, id: @species_location
    end

    assert_redirected_to species_locations_path
  end
end
