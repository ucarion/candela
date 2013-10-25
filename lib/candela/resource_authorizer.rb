module Candela
  class ResourceAuthorizer
    # Though this may look weird, it's actually a pretty effective way
    # at creating a class that adds functionality to a controller without
    # polluting its namespace. In all other methods, `self` will refer to
    # a ResourceAuthorizer, not any controller.
    def self.add_before_filter(controller_class, method_name, opts)
      controller_class.before_filter do |controller|
        ResourceAuthorizer.new(controller, opts).send(method_name)
      end
    end

    def initialize(controller, opts)
      @controller = controller
      @opts = {
        names: default_resource_names
      }.merge(opts)
    end

    def authorize_resource
      # Initialize the resource ...
      @controller.send(:__load_from_resources_block)

      check_can_access_resource(resource_to_authorize)
    end

    private

    def check_can_access_resource(resource)
      unless current_ability.can?(current_action, resource)
        raise Candela::AccessDeniedError
      end
    end

    def resource_to_authorize
      @opts[:names].each do |resource_name|
        resource = resource_ivar_from_name(resource_name)

        return resource if resource
      end
    end

    def current_action
      @controller.action_name.to_sym
    end

    def current_ability
      @controller.current_ability
    end

    def resource_ivar_from_name(resource_name)
      @controller.instance_variable_get("@#{resource_name}")
    end

    def default_resource_names
      plural_model_name = @controller.controller_name

      [ plural_model_name.singularize, plural_model_name ]
    end
  end
end
