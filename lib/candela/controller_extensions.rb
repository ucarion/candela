module Candela
  module ControllerExtensions
    extend ActiveSupport::Concern

    included do
      
    end

    module ClassMethods
      def authorize_resource(opts = {})
        ControllerAdditions.authorize_resource(self, opts)
      end
    end
  end
end

ActionController::Base.send :include, Candela::ControllerExtensions
