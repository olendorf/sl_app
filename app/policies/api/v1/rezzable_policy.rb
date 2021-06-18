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
        @user.active?
      end

      def create?
        return true if @user.can_be_owner?
        return false unless @user.active?
        begin
          object_weight = @record.class::OBJECT_WEIGHT
        rescue 
          object_weight = @record::OBJECT_WEIGHT
        end
        @user.check_object_weight(object_weight)
      end

      # class Scope < Scope
      #   def resolve
      #     scope.all
      #   end
      # end
    end
  end
end
