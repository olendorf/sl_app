# frozen_string_literal: true

module Api
  module V1
    module Analyzable
      # Authorization for prcels
      class ParcelPolicy < ApplicationPolicy
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
      end
    end
  end
end
