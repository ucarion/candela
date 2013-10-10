require 'test_helper'

class AuthorizeNestedResourceTest < ActionController::TestCase
  tests PostsController

  def setup
    @user = User.create(name: "foo", password: "bar")
    @post = @user.posts.create(content: "Foo bar")
  end

  test "load through params[:id] for #show" do
    get(:show, id: @post.id)

    assert_not_nil assigns(:post)
  end

  test "load through assocation for #new" do
    get(:new, user_id: @user.id)

    assert_not_nil assigns(:post)

    assert_equal assigns(:post).user_id, @user.id
  end
end
