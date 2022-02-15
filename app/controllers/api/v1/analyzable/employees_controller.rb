# frozen_string_literal: true

module Api
  module V1
    module Analyzable
      # Controller for employees and the time cop apyments
      class EmployeesController < Api::V1::AnalyzableController
        
        def create
          authorize @requesting_object
          ::Analyzable::Employee.create!(
            atts.merge(user_id: @requesting_object.user.id)
          )
          render json: {message: 'Created'}, status: :created
        end
        
        def index 
          authorize @requesting_object
          employees = @requesting_object.user.employees.order(:avatar_name)
          params['employee_page'] ||= 1
          page = employees.page(params['employee_page']).per(9)
          data = paged_data(page)
          render json: {message: 'OK', data: data}, status: :ok
        end
        
        def show
          authorize @requesting_object
          @employee = @requesting_object.user.employees.find_by_avatar_key(params['id'])
          render json: {
            message: 'Found', 
            data: @employee.attributes.except(
              'id', 
              'created_at', 
              'updated_at',
              'user_id')
          }, status: :ok
        end
        
        def update
          authorize @requesting_object
          @employee = @requesting_object.user.employees.find_by_avatar_key(params['id'])
          @employee.update!(atts)
          render json: {message: 'Updated'}, status: :ok
        end
        
        def destroy 
          authorize @requesting_object
          @employee = @requesting_object.user.employees.find_by_avatar_key(params['id'])
          @employee.destroy!
          render json: {message: 'Employee terminated'}, status: :ok
        end
        
        private

        def paged_data(page)
          {
            employees: page.collect do |e| 
              { avatar_name: e.avatar_name, avatar_key: e.avatar_key }
            end,
            current_page: page.current_page,
            next_page: page.next_page,
            prev_page: page.prev_page,
            total_pages: page.total_pages
          }
        end
        
        # def create
        #   authorize @requesting_object
        #   ::Analyzable::Parcel.create(
        #     atts.merge({ requesting_object: @requesting_object,
        #                 user_id: @requesting_object.user.id })
        #   )
        #   # parcel.parcel_box = @requesting_object
        #   # @requesting_object.user.parcels << parcel
        #   # parcel.states << ::Analyzable::ParcelState.new(state: 'for_sale')
        #   render json: { message: 'Created' }, status: :created
        # end

        # def show
        #   authorize @requesting_object
        #   data = @requesting_object.parcel.attributes.except(
        #     'id', 'user_id', 'parcel_box_id', 'updated_at', 'created_at'
        #   )
        #   render json: { message: 'OK', data: data }, status: :ok
        # end

        # def update
        #   authorize @requesting_object
        #   @parcel = ::Analyzable::Parcel.find(params['id'])
        #   @parcel.update(atts.merge(requesting_object: @requesting_object))
        #   render json: { message: 'Updated' }, status: :ok
        # end

        # # rubocop:disable Metrics/AbcSize
        # def index
        #   authorize @requesting_object
        #   params['parcel_page'] ||= 1
        #   params['scope'] ||= 'region'
        #   parcels = @requesting_object.user.parcels.where(
        #     region: @requesting_object.region
        #   ) if params['scope'] == 'region'
        #   parcels = @requesting_object.user.parcels.where(
        #     owner_key: params['owner_key']
        #   ) if params['scope'] == 'renter'
        #   page = parcels.page(params['parcel_page']).per(9)
        #   data = paged_data(page)
        #   render json: { message: 'OK', data: data }, status: :ok
        # end
        # # rubocop:enable Metrics/AbcSize

        # private

        # def paged_data(page)
        #   {
        #     parcels: page.collect { |p| { parcel_name: p.parcel_name, id: p.id } },
        #     current_page: page.current_page,
        #     next_page: page.next_page,
        #     prev_page: page.prev_page,
        #     total_pages: page.total_pages
        #   }
        # end
      end
    end
  end
end
