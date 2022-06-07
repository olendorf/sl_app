# frozen_string_literal: true

module Api
  module V1
    # Authorization for Users
    class UserPolicy < ApplicationPolicy
      def create?
        true
      end

      def show?
        @user.can_be_owner?
      end

      def update?
        show?
      end

      def destroy?
        show?
      end
    end
  end
end
