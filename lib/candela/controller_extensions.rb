module Candela
  module ControllerExtensions
    extend ActiveSupport::Concern

    module ClassMethods
      # Creates a before_filter which will load a resource into an instance
      # variable, then make sure that loaded variable can be accessed.
      # 
      # The process of loading the resource is quite straightforward. Consider
      # this usage of the authorize_resource method:
      # 
      #   class ArticlesController < ApplicationController
      #     authorize_resource
      #   end
      # 
      # Then, the @article variable will be populated as:
      # 
      #   #new          => Article.new
      #   #create       => Article.create(article_params)
      #   anything else => Article.find(params[:id])
      # 
      # If your resource is in fact a nested one, then use the `parent` parameter
      # when calling authorize_resouce, passing the singular name of the parent 
      # class as the value of `parent`:
      # 
      #   class CommentsController < ApplicationController
      #     authorize_resource parent: :article
      #   end
      # 
      # Resource loading will remain largely unchanged, but loading for the #new
      # action will be modified:
      # 
      #   #new => Article.find(params[:article_id]).comments.new
      # 
      # Options:
      # [:+params+]
      #   The method to call on the controller to create a model. By default, this
      #   will be the singular name of the model with "_params" concatenated.
      # [:+parent+]
      #   If this model is a nested one, then set this value to be the singular name
      #   of the parent model.
      # 
      def authorize_resource(opts = {})
        ResourceAuthorizer.add_before_filter(self, :authorize_resource, opts)
      end
    end

    def current_ability
      @current_ability ||= ::Ability.new(current_user)
    end
  end
end

ActionController::Base.send :include, Candela::ControllerExtensions
