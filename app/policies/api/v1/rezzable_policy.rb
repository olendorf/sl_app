# frozen_string_literal: true

module Api
  module V1
    # Base policy class for all rezzable.
    class RezzablePolicy < ApplicationPolicy
      def show?
        true
      end

      def destroy?
        show?
      end

      def update?
        # return true if @user.can_be_owner?
        @user.active?
      end

      def create?
        @user.active?
      end

      # class Scope < Scope
      #   def resolve
      #     scope.all
      #   end
      # end
    end
  end
end
