module Candela
  module ControllerExtensions
    extend ActiveSupport::Concern

    module ClassMethods
      def authorize_resource(opts = {})
        ControllerAdditions.authorize_resource(self, opts)
      end
    end

    def current_ability
      @current_ability ||= ::Ability.new(current_user)
    end
  end
end

ActionController::Base.send :include, Candela::ControllerExtensions
