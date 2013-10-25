module Candela
  module ControllerExtensions
    extend ActiveSupport::Concern

    included do
      helper_method :can?, :current_ability
    end

    module ClassMethods
      # name: 'tortilla' => @tortilla or @tortillas
      def authorize_resource(opts = {})
        ResourceAuthorizer.add_before_filter(self, :authorize_resource, opts)
      end

      attr_reader :load_resources_block

      def load_resources(&block)
        @load_resources_block = block
      end
    end

    def can?(*args)
      current_ability.can?(*args)
    end

    # Loads the ability of the current user. This method assumes that you have
    # named your own ability class "Ability", and that you have defined a method
    # called `current_user`.
    def current_ability
      @current_ability ||= ::Ability.new(current_user)
    end

    def __load_from_resources_block
      ResourceLoader.new(self).instance_eval(&self.class.load_resources_block)
    end
  end
end

ActionController::Base.send :include, Candela::ControllerExtensions
