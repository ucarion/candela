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
      @params = @controller.params
      @opts = {
        params: default_params_names
      }.merge(opts)
    end

    def authorize_resource
      loaded_resource = case action
      when :index
        load_resource_for_action_index
      when :new
        load_resource_for_action_new
      when :create
        load_resource_for_action_create
      else
        load_resource_from_id unless action_is_on_collection?
      end

      check_can_access_resource(loaded_resource)
    end

    private

    def check_can_access_resource(resource)
      unless (action_is_on_collection? ?
          can_access_collection_action? : can_access_member_action?(resource))
        raise AccessDeniedError
      end
    end

    def action_is_on_collection?
      # If params[:id] is nil, then this action isn't working on any individual
      # model instance; therefore, this action is working on a collection.
      # 
      # The #new and #create actions are exceptions, since they're technically
      # collection actions, but create a model instance we can work with for
      # authentication purposes and so we consider them to be member actions.
      [:new, :create].exclude?(action) && @params[:id].nil?
    end

    def can_access_collection_action?
      current_ability.can?(action, model_class)
    end

    def can_access_member_action?(resource)
      current_ability.can?(action, resource)
    end

    def action
      @params[:action].to_sym
    end

    def load_resource_for_action_index
      accessible_models = []

      model_class.find_each do |model|
        accessible_models << model if current_ability.can?(:show, model)
      end

      set_resource_instance_var(accessible_models, true)
    end

    def load_resource_for_action_new
      if @opts[:parent]
        child = parent_model.find(parent_id).send(plural_model_name).new
        set_resource_instance_var(child)
      else
        set_resource_instance_var(model_class.new)
      end
    end

    def load_resource_for_action_create
      set_resource_instance_var(model_class.create(strong_params))
    end

    def load_resource_from_id
      set_resource_instance_var(model_class.find(@params[:id]))
    end

    def set_resource_instance_var(value, plural = false)
      ivar_name = "@#{plural ? plural_model_name : singular_model_name}"
      @controller.instance_variable_set(ivar_name, value)
    end

    def current_ability
      @controller.current_ability
    end

    def parent_model
      @opts[:parent].to_s.camelize.constantize
    end

    def parent_id
      @params[@opts[:parent].to_s.foreign_key]
    end

    def default_params_names
      "#{singular_model_name}_params"
    end

    # TODO: A better name for this?
    def strong_params
      @controller.send(@opts[:params])
    end

    def model_class
      singular_model_name.classify.constantize
    end

    def singular_model_name
      plural_model_name.singularize
    end

    def plural_model_name
      @controller.controller_name
    end
  end
end
