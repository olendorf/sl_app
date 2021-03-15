# frozen_string_literal: true

module ActiveAdmin
  # Common behavior for Active Admin Rezzable Controllers.
  # Primarily for interacting with in world objecs but could be other things.
  module InventoryBehavior
    extend ActiveSupport::Concern
    
    def self.included(base)
      # member_action :give, method: :post do
      # end
    end
  end
end
