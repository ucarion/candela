require 'test_helper'

class AuthorizeResourceTest < ActionController::TestCase
  tests UsersController

  def setup
    @user = User.create(name: "foo", password: "bar")
    @controller.current_user = @user
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

  test "loading from params[:id] on non-CRUD actions" do
    get(:upcasename, id: 1)

    assert_not_nil assigns(:user)

    assert_equal User.find(1).name, "FOO"
  end

  test "loading readable instances on #index" do
    get(:index)

    assert_not_nil assigns(:users)

    User.all.each do |user|
      assert assigns(:users).include?(user)
    end
  end

  test "not loading anything on non-index collection actions" do
    get(:listall)

    assert_nil assigns(:user)
    assert_nil assigns(:users)
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
