module Candela
  class Rule
    def initialize(action, model, block)
      @action, @model, @block = action, model, block
    end

    # TODO: Find a better name for this method.
    def applies?(action, object)
      if @block
        @block.call(object)
      else
        true
      end
    end

    def relevant?(action, object)
      return false unless action == @action

      if object.is_a?(ActiveRecord::Relation)
        object.model == @model
      else
        object.class == @model
      end
    end
  end
end
