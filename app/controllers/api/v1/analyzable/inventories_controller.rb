# frozen_string_literal: true

module Api
  module V1
    module Analyzable
      # Handles requests to the Inventory API
      class InventoriesController < Api::V1::AnalyzableController
        def create
          authorize [:api, :v1, @requesting_object]

          begin
            @inventory = @requesting_object.actable.inventories
                                           .find_by_inventory_name!(atts['inventory_name'])
            update
          rescue ActiveRecord::RecordNotFound
            @requesting_object.inventories << ::Analyzable::Inventory.new(atts)
            render json: { message: 'Created' }, status: :created
          end
        end

        def update
          authorize [:api, :v1, @requesting_object]
          load_inventory unless @inventory
          @inventory.update(atts)
          render json: { message: 'Updated' }, status: :ok
        end

        def index
          authorize [:api, :v1, @requesting_object]

          params['inventory_page'] ||= 1
          page = @requesting_object.actable.inventories
                                   .page(params['inventory_page']).per(9)
          data = paged_data(page)
          render json: { data: data }, status: :ok
        end

        def show
          authorize [:api, :v1, @requesting_object]
          @inventory = ::Analyzable::Inventory.find_by_inventory_name!(params['id'])
          data = @inventory.attributes.except(:id, :user_id, :server_id, :created_at, :updated_at)
          render json: { message: 'OK', data: data }, status: :ok
        end

        def destroy
          authorize [:api, :v1, @requesting_object]
          if params['id'] == 'all'
            @requesting_object.inventories.destroy_all
          else
            @inventory = ::Analyzable::Inventory.find_by_inventory_name!(params['id'])
            @inventory.destroy!
          end
          render json: { message: 'OK' }, status: :ok
        end

        private

        def paged_data(page)
          {
            inventory: page.map(&:inventory_name),
            current_page: page.current_page,
            next_page: page.next_page,
            prev_page: page.prev_page,
            total_pages: page.total_pages
          }
        end
      end
    end
  end
end
