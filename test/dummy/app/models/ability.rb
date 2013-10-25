class Ability < Candela::Ability
  def initialize(user)
    can :show, User
    can :edit, User
    can :update, User
    can :new, User
    can :create, User
    can :destroy, User
    can :upcasename, User
    can :index, User
    can :listall, User
  end
end
