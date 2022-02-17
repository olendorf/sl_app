# frozen_string_literal: true

module Api
  module V1
    module Analyzable
      # Authorization for employee api
      class EmployeePolicy < ApplicationPolicy
        def create?
          @user.active?
        end

        def show?
          create?
        end

        def update?
          create?
        end

        def index?
          create?
        end

        def destroy?
          create?
        end

        def pay?
          create?
        end

        def pay_all?
          create?
        end
      end
    end
  end
end
