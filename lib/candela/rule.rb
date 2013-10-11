module Candela
  class Rule
    def initialize(action, model, opts, block)
      @action, @model, @opts, @block = action, model, opts, block
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
      action == @action && if @opts[:collection]
        object == @model
      else
        object.class == @model
      end
    end
  end
end
