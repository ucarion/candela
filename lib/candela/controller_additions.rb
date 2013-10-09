module Candela
  module ControllerAdditions
    def self.authorize_resource(controller_class, opts)
      controller_name = controller_class.controller_name
      instance_name = controller_name.singularize 

      controller_class.prepend_before_filter do |controller|
        params = controller.params
        model = params[:controller].classify.constantize

        case params[:action].to_sym
        when :new
          controller.instance_variable_set("@#{instance_name}", model.new)
        when :show, :edit
          controller.instance_variable_set("@#{instance_name}", model.find(params[:id]))
        end
      end
    end
  end
end
