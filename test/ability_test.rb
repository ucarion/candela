require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "John", password: "password")

    @ability = Object.new
    @ability.extend(Candela::Ability)
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

  test "abilities return false if can block returns true" do
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

  test "can collection: true lets you call can? on a model class" do
    @ability.can :index, User, collection: true

    assert @ability.can? :index, User
  end
end
