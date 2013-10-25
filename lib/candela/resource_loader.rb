module Candela
  class ResourceLoader
    def initialize(controller)
      @controller = controller
    end

    def before(*actions, &block)
      if actions.include?(@controller.action_name.to_sym)
        @controller.instance_eval(&block)
      end
    end
  end
end
