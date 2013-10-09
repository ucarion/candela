require 'test_helper'

class AuthorizeResourceTest < ActionController::TestCase
  tests UsersController

  def setup
    User.create(name: "foo", password: "bar")
  end

  test "loading from params[:id] on show" do
    get(:show, id: 1)

    assert_not_nil assigns(:user)
  end
end
