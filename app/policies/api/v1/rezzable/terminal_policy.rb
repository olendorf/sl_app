# frozen_string_literal: true

module Api
  module V1
    module Rezzable
      # Set permission sfor terminals inheriting form Owner object policy.
      class TerminalPolicy < Api::V1::OwnerObjectPolicy
      end
    end
  end
end
