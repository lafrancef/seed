require 'test_helper'

class TreesControllerTest < ActionController::TestCase
	test "new" do
		get :new
		assert_response :success
	end
	
	test "create" do
		aardvark = "Aardvark"
		post :create, {tree: {name: aardvark} }
		
		assert_redirected_to tree_path(assigns(:tree))
		print @response.body
		assert_equal(aardvark, assigns["tree"].name)
	end
end
