class Ability
  include Candela::Ability

  def initialize(user)
    can :show, User
    can :edit, User
    can :update, User
    can :new, User
    can :create, User
    can :destroy, User
    can :upcasename, User

    can :show, Post
    can :new, Post
  end
end
