# frozen_string_literal: true

module Api
  module V1
    module Rezzable
      # Controller for Rezzable Donation Boxes
      class DonationBoxesController < Api::V1::AbstractWebObjectsController
        def update
          enrich_atts if @atts['transactions_attributes']
          super
        end

        private

        def enrich_atts
          @message = @requesting_object.response
          @atts['transactions_attributes'][
            0]['category'] = 'donation'
          @atts['transactions_attributes'][
            0]['source_key'] = @requesting_object.object_key
          @atts['transactions_attributes'][
            0]['source_name'] = @requesting_object.object_name
          @atts['transactions_attributes'][
            0]['source_type'] = 'donation box'
          @atts['transactions_attributes'][
            0]['description'] = 'Donation from '\
                      "#{@atts['transactions_attributes'][0]['target_name']}."
        end
      end
    end
  end
end
