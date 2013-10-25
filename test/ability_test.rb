require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "John", password: "password")

    @ability = Candela::Ability.new
  end

  test "abilities have #can, #can? methods defined" do
    assert_respond_to @ability, :can
    assert_respond_to @ability, :can?
  end

  test "abilities by default do not allow any actions" do
    assert_not @ability.can? :read, User
  end

  test "abilities explicity allowed are permitted" do
    @ability.can :read, User

    assert @ability.can? :read, @user
  end

  test "cannots supercede cans" do
    @ability.cannot :read, User
    @ability.can :read, User

    assert_not @ability.can? :read, @user
  end

  test "abilities return true if can block returns true" do
    @ability.can :read, User do |user|
      user.name.starts_with?("J")
    end

    assert @ability.can? :read, @user
  end

  test "abilities return false if can block returns false" do
    @ability.can :read, User do
      false
    end

    assert_not @ability.can? :read, @user
  end

  test "can? returns true if any can passes" do
    @ability.can :read, User do
      false
    end

    @ability.can :read, User do 
      true
    end

    assert @ability.can? :read, @user
  end

  test "can? returns false if no rules are relevant" do
    @ability.can :update, User

    assert_not @ability.can? :read, @user
  end

  test "can? works with ActiveRecord::Relation arguments" do
    @ability.can :index, User

    assert @ability.can? :index, User.all
  end

  test "can :update automatically provides can? :edit" do
    @ability.can :update, User

    assert @ability.can? :edit, @user
  end

  test "cannot :update automatically disallows can? :edit" do
    @ability.cannot :update, User

    assert_not @ability.can? :edit, @user
  end

  test "can :create automatically provides can? :new" do
    @ability.can :create, User

    assert @ability.can? :new, @user
  end

  test "can :read automatically provides can? :show" do
    @ability.can :read, User

    assert @ability.can? :read, @user # how the user will test it
    assert @ability.can? :show, @user # show Candela will test it
  end

  test "#can accepts array of actions to permit" do
    @ability.can [ :read, :update, :destroy ], User

    assert @ability.can? :read, @user
    assert @ability.can? :edit, @user
    assert @ability.can? :update, @user
    assert @ability.can? :destroy, @user
  end

  test "#alias_action will allow one action to be aliased for another" do
    @ability.alias_action :destroy, to: :delete
    @ability.can :delete, User

    assert @ability.can? :delete, @user
    assert @ability.can? :destroy, @user
  end

  test "#alias_action will allow multiple actions to be aliased as one action" do
    @ability.alias_action :create, :read, :update, :destroy, to: :crud
    @ability.can :crud, User
    
    assert @ability.can? :crud, @user
    %i(create read update destroy).each do |action|
      assert @ability.can? action, @user
    end
  end
end
