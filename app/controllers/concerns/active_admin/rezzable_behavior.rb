# frozen_string_literal: true

module ActiveAdmin
  # Common behavior for Active Admin Rezzable Controllers.
  # Primarily for interacting with in world objecs but could be other things.
  module RezzableBehavior
    extend ActiveSupport::Concern

    def self.included(base)
      base.controller do
        
        def update
          RezzableSlRequest.update_web_object!(
            resource, 
            params[resource.class.name.underscore.gsub('/', '_')]
          )
          super
        end
        
        def destroy
          RezzableSlRequest.derez_web_object!(resource)
          super
        end
      end
    end
  end
end
