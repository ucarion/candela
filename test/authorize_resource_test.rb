require 'test_helper'

class AuthorizeResourceTest < ActionController::TestCase
  tests UsersController

  def setup
    @user = User.create(name: "foo", password: "bar")
    @controller.current_user = @user
  end
  
  test "not raising exceptions on permitted actions" do
    assert_nothing_raised do
      # Dummy app has a pre-existing Ability class that allows anyone to read users.
      get(:show, id: @user.id)
    end
  end

  test "raising exceptions on non-permitted actions" do
    assert_raises Candela::AccessDeniedError do
      get(:unpermitted, id: @user.id)
    end
  end
end
