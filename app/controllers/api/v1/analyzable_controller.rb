# frozen_string_literal: true

module Api
  module V1
    # Parent controll for all rezzable objects
    class AnalyzableController < Api::V1::ApiController
      
      skip_before_action :load_requesting_object, except: [:create]
      prepend_before_action :load_requesting_object
      
      
      private
      
      def atts 
        JSON.parse(request.raw_post)
      end 
      
      def api_key
        @requesting_object.api_key
      end
    end
  end 
end 
