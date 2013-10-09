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

  test "loading from params[:id] on edit" do
    get(:edit, id: 1)

    assert_not_nil assigns(:user)
  end

  test "creating a new model on new" do
    get(:new)

    assert_not_nil assigns(:user)
  end

  test "creating a new model on create" do
    post(:create, user: { name: "John", password: "secret" })

    assert_response :found

    assert User.where(name: "John").present?
  end

  test "using params for create" do
    assert_raises ActionController::ParameterMissing do
      post(:create, not_user: { name: "John", password: "secret" })
    end
  end

  test "loading from params[:id] on update" do
    patch(:update, id: 1, user: { name: "oof", password: "rab" })

    assert_not_nil assigns(:user)

    assert_equal User.find(1).name, "oof"
  end

  test "loading from params[:id] on destroy" do
    to_destroy = User.create(name: "delete", password: "me")

    delete(:destroy, id: to_destroy.id)

    assert_not_nil assigns(:user)
  end
end
