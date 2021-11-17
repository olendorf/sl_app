# frozen_string_literal: true

module Api
  module V1
    # Authorization for service ticket request from SL
    class ServiceTicketPolicy < ApplicationPolicy
      def show?
        @user.can_be_owner?
      end

      def create?
        show?
      end

      def update?
        show?
      end

      def index?
        show?
      end
    end
  end
end
