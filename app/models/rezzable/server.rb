# frozen_string_literal: true

module Rezzable
  # Model for in world inventory servers
  class Server < ApplicationRecord
    acts_as :abstract_web_object

    has_many :clients, class_name: 'AbstractWebObject', dependent: :nullify
    has_many :inventories, class_name: 'Analyzable::Inventory', 
                           dependent: :destroy, 
                           before_add: :set_user
    accepts_nested_attributes_for :inventories, allow_destroy: true

    # rubocop:disable Style/RedundantSelf
    def response_data
      { api_key: self.api_key }
    end
    # rubocop:enable Style/RedundantSelf
    
    
    private
    
      def set_user(inventory)
        inventory.user_id = user.id
      end
  end
end
