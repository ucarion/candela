module Candela
  module Ability
    # Checks if this ability is allowed to perform a given action on some object.
    #
    # If any relevant #cannot call apply here, then this method will return false.
    # Then, any relevant #can calls will cause this method to return true. Finally,
    # if there are no relevant rules to the action-object pair passed, then this
    # method defaults to returning false.
    def can?(action, object)
      # First, check if any cannots negate this permission.
      cannots.each do |cannot|
        if cannot.relevant?(action, object, aliases[action])
          return false if cannot.applies?(action, object)
        end
      end

      # Next, see if any cans provide this permission
      cans.each do |can|
        if can.relevant?(action, object, aliases[action])
          return true if can.applies?(action, object)
        end
      end

      # There were no relevant rules, so fall back to default behavior
      false
    end

    # Defines an action which this Ability is allowed to perform. In the simplest
    # case, this function takes two arguments: the action that is permitted, and
    # the model this action can be performed on. For instance,
    #
    #   can :read, Post
    #
    # Would allow this ability to access the #read action on PostsController.
    #
    # If the permission to perform an action is dependent on some property of the
    # model being accessed, then this method can also accept a block. For example,
    # if you can only read a post if that post is by a friend, then you might do
    # something like this:
    #
    #   can :read, Post do |post|
    #     post.author.friends.include?(current_user)
    #   end
    #
    # The "post" variable that's being passed to the block is the model being
    # accessed. As long as the block returns a truthy value, the permission to
    # perform the described action is granted.
    def can(action, model, opts = {}, &block)
      add_rule(cans, action, model, opts, block)
    end

    # Explicitly disallows an action to be performed by this Ability. A #cannot
    # will always supercede any #can; if you do something like
    #
    #   cannot :read, Post
    #   can :read, Post
    #
    # Then
    #
    #   can? :read, @post
    #
    # Will return false.
    #
    # Much like #can, this method can accept a block. See the documentation for
    # #can to get an idea of how that works.
    def cannot(action, model, opts = {}, &block)
      add_rule(cannots, action, model, opts, block)
    end

    private

    def add_rule(rule_array, action, model, opts, block)
      if action.is_a?(Array)
        action.each do |passed_action|
          rule_array << Rule.new(passed_action, model, opts, block)
        end
      else
        rule_array << Rule.new(action, model, opts, block)
      end
    end

    def cans
      @cans ||= []
    end

    def cannots
      @cannots ||= []
    end

    DEFAULT_ALIASES = {
      edit: :update,
      new: :create,
      show: :read
    }

    def aliases
      @aliases ||= DEFAULT_ALIASES
    end
  end
end
