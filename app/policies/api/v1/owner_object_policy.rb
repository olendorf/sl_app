# frozen_string_literal: true

module Api
  module V1
    # Base policy for owner objects. Object that should only
    # be rezzed by owners of this system should inherit from this.
    class OwnerObjectPolicy < Api::V1::RezzablePolicy
      def show?
        @user.can_be_owner?
      end

      def create?
        show?
      end

      def update?
        show?
      end

      def destroy?
        show?
      end

      # class Scope < Scope
      #   def resolve
      #     scope.all
      #   end
      # end
    end
  end
end
