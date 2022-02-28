# frozen_string_literal: true

module Api
  module V1
    module Analyzable
      # Controller for employees and the time cop apyments
      class EmployeesController < Api::V1::AnalyzableController
        before_action :load_employee, except: %i[index pay_all]

        def create
          authorize [:api, :v1, @requesting_object]
          @employee = ::Analyzable::Employee.create!(
            atts.merge(user_id: @requesting_object.user.id)
          )

          render json: {
            message: I18n.t('api.analyzable.employee.create'),
            avatar: @employee.avatar_name
          }, status: :created
        end

        def index
          authorize [:api, :v1, @requesting_object]
          employees = @requesting_object.user.employees.order(:avatar_name)
          params['employee_page'] ||= 1
          page = employees.page(params['employee_page']).per(9)
          data = paged_data(page)
          render json: { message: 'OK', data: data }, status: :ok
        end

        def show
          authorize [:api, :v1, @requesting_object]
          render json: {
            message: 'Found',
            data: @employee.attributes.except(
              'id',
              'created_at',
              'updated_at',
              'user_id'
            )
          }, status: :ok
        end

        def update
          authorize [:api, :v1, @requesting_object]
          raise ActiveRecord::RecordNotFound,
                I18n.t('api.analyzable.employee.not_found') unless @employee

          @employee.update!(atts)
          render json: { message: update_message }, status: :ok
        end

        def destroy
          authorize [:api, :v1, @requesting_object]
          @employee.destroy!
          render json: {
            message: I18n.t('api.analyzable.employee.destroy',
                            avatar: @employee.avatar_name)
          }, status: :ok
        end

        def pay
          authorize [:api, :v1, @requesting_object]
          @employee.update_columns(hours_worked: 0, pay_owed: 0)
          pay_employee(@employee)
          render json: {
            message: I18n.t('api.analyzable.employee.pay',
                            avatar: @employee.avatar_name)
          }, status: :ok
        end

        def pay_all
          authorize [:api, :v1, @requesting_object]
          @requesting_object.user.employees.each do |employee|
            pay_employee(employee)
          end

          render json: {
            message: I18n.t('api.analyzable.employee.pay_all')
          }, status: :ok
        end

        private

        def pay_employee(employee)
          PayUserWorker.perform_async(
            @requesting_object.user.servers.sample.id,
            employee.avatar_name, employee.avatar_key, employee.pay_owed
          )
          @requesting_object.user.transactions << ::Analyzable::Transaction.new(
            amount: -1 * employee.pay_owed,
            category: 'employee_payment',
            target_name: employee.avatar_name,
            target_key: employee.avatar_key
          )
        end

        def load_employee
          @employee = @requesting_object.user.employees.find_by_avatar_key(params['id'])
        end

        def update_message
          if atts['work_session']
            I18n.t('api.analyzable.employee.clocked_in')
          else
            'Updated'
          end
        end

        def paged_data(page)
          {
            employees: page.collect do |e|
              { avatar_name: e.avatar_name, avatar_key: e.avatar_key }
            end,
            current_page: page.current_page,
            next_page: page.next_page,
            prev_page: page.prev_page,
            total_pages: page.total_pages,
            total_pay: total_pay

          }
        end

        def total_pay
          @requesting_object.user.work_sessions.sum(:pay)
        end
      end
    end
  end
end
