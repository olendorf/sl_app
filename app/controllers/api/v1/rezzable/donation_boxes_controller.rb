# frozen_string_literal: true

module Api
  module V1
    module Rezzable
      # Controller for Rezzable Donation Boxes
      class DonationBoxesController < Api::V1::AbstractWebObjectsController
        def update
          logger.info("UPdate in donation box")
          @message = @requesting_object.response if @atts['transactions_attributes']
          super
        end
      end
    end
  end
end
