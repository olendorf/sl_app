# frozen_string_literal: true

module Api
  module V1
    module Rezzable
      # Controller for servers
      class WebObjectsController < Api::V1::AbstractWebObjectsController
        def show
          authorize [:api, :v1, @requesting_object]
          render json: {
            message: 'Success!'
          }
        end
      end
    end
  end
end
