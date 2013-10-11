module Candela
  module ControllerAdditions
    def self.authorize_resource(controller_class, opts)
      controller_name = controller_class.controller_name
      instance_name = controller_name.singularize

      controller_class.prepend_before_filter do |controller|
        model = params[:controller].classify.constantize

        case params[:action].to_sym
        when :new
          if opts[:parent]
            parent_class = opts[:parent].to_s.classify.constantize
            parent_id = params["#{opts[:parent]}_id"]

            instance = parent_class.find(parent_id).send(controller_name).new

            instance_variable_set("@#{instance_name}", instance)
          else
            instance_variable_set("@#{instance_name}", model.new)
          end
        when :create
          created_instance = model.new(send(opts[:params]))
          instance_variable_set("@#{instance_name}", created_instance)
        else
          instance_variable_set("@#{instance_name}", model.find(params[:id]))
        end
      end
    end
  end
end
