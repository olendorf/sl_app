# frozen_string_literal: true

module Api
  module V1
    module Rezzable
      # Default policy for all web objects.
      class WebObjectPolicy < ApplicationPolicy
        def show?
          true
        end

        def create?
          true
        end

        def update?
          true
        end

        def index?
          true
        end

        def destroy?
          true
        end
      end
    end
  end
end
